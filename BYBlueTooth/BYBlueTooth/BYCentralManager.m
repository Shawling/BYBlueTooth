//
//  BYCentralManager.m
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import "BYCentralManager.h"

@implementation BYCentralManager

- (instancetype)init {
	self = [super init];
	if (self) {
		
		
#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
								 //蓝牙power没打开时alert提示框
								 [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
								 //重设centralManager恢复的IdentifierKey
								 @"byBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
								 nil];
		
#else
		NSDictionary *options = nil;
#endif
		
		NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
		if ([backgroundModes containsObject:@"bluetooth-central"]) {
			//后台模式
			centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
		}
		else {
			//非后台模式
			centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
		}
		
		pocket = [[NSMutableDictionary alloc]init];
		discoverPeripherals = [[NSMutableArray alloc]init];
		reConnectPeripherals = [[NSMutableArray alloc]init];
	}
	return  self;
	
}

#pragma mark - 接收到通知

//扫描Peripherals
- (void)scanPeripherals {
	[centralManager scanForPeripheralsWithServices:nil options:nil];
}

//连接Peripherals
- (void)connectToPeripheral:(CBPeripheral *)peripheral{
	[centralManager connectPeripheral:peripheral options:nil];
}

//断开设备连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
	[centralManager cancelPeripheralConnection:peripheral];
}

//停止扫描
- (void)cancelScan {
	[centralManager stopScan];
}


#pragma mark - CBCentralManagerDelegate委托方法

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
	
	switch (central.state) {
		case CBCentralManagerStateUnknown:
			BYLog(@">>>CBCentralManagerStateUnknown");
			break;
		case CBCentralManagerStateResetting:
			BYLog(@">>>CBCentralManagerStateResetting");
			break;
		case CBCentralManagerStateUnsupported:
			BYLog(@">>>CBCentralManagerStateUnsupported");
			break;
		case CBCentralManagerStateUnauthorized:
			BYLog(@">>>CBCentralManagerStateUnauthorized");
			break;
		case CBCentralManagerStatePoweredOff:
			BYLog(@">>>CBCentralManagerStatePoweredOff");
			break;
		case CBCentralManagerStatePoweredOn:
			BYLog(@">>>CBCentralManagerStatePoweredOn");
			break;
		default:
			break;
	}
	
	for (NSString *key in byCallBack.blocksOnCentralManagerDidUpdateState) {
		byCallBack.blocksOnCentralManagerDidUpdateState[key](central);
	}
}

//扫描到Peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

	if ([self addDiscoverPeripheral:peripheral]) {
		BYLog(@">>>扫描到设备:%@",peripheral.name);
		//扫描到设备callback
		if ([byCallBack filterOnDiscoverPeripherals]) {
			if ([byCallBack filterOnDiscoverPeripherals](peripheral.name,advertisementData,RSSI)) {
				if ([byCallBack blockOnDiscoverPeripherals]) {
					for (NSString *key in byCallBack.blockOnDiscoverPeripherals) {
						byCallBack.blockOnDiscoverPeripherals[key](central,peripheral,advertisementData,RSSI);
					}
				}
			}
		}
	}
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
	//设置委托
	[peripheral setDelegate:self];
	
	BYLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
	self->cachedPeripheral = peripheral;
	self->connectedPeripheral = peripheral;
	
	//执行回叫
	//扫描到设备callback
	if ([byCallBack blockOnConnectedPeripheral]) {
		for (NSString *key in byCallBack.blockOnConnectedPeripheral) {
			byCallBack.blockOnConnectedPeripheral[key](central,peripheral);
		}
	}
	
	//扫描外设的服务
	if (needDiscoverServices) {
		[peripheral discoverServices:nil];
	}
}

//连接到Peripherals-失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	BYLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);

	//扫描到设备callback
	if ([byCallBack blockOnFailToConnect]) {
		for (NSString *key in byCallBack.blockOnFailToConnect) {
			byCallBack.blockOnFailToConnect[key](central,peripheral,error);
		}
	}
}

//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
	if (error)
	{
		BYLog(@">>> 外设连接断开连接 %@  错误信息: %@", peripheral.name, [error localizedDescription]);
	}
	
	self->connectedPeripheral = nil;
	if ([byCallBack blockOnDisconnect]) {
		for (NSString *key in byCallBack.blockOnDisconnect) {
			byCallBack.blockOnDisconnect[key](central,peripheral,error);
		}
	}
}

#pragma mark - 私有方法	- 设备list管理

- (BOOL)addDiscoverPeripheral:(CBPeripheral *)peripheral{
	if (![discoverPeripherals containsObject:peripheral]) {
		[discoverPeripherals addObject:peripheral];
		return YES;
	}
	return NO;
}

@end
