//
//  BYBlueTooth.m
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import "BYBlueTooth.h"
#import "BYCallBack.h"
#import "BYCentralManager.h"

@implementation BYBlueTooth {
	BYCentralManager* byCentralManager;
	BYCallBack* byCallBack;
	//BYCentralManager等待打开次数，每KBY_CENTRAL_MANAGER_INIT_WAIT_SECOND等待计数一次
	int CENTRAL_MANAGER_INIT_WAIT_TIMES;
	NSTimer *timerForStop;
}

//单例模式
+(instancetype) shareBYBlueTooth {
	static BYBlueTooth *share = nil;
	static dispatch_once_t oneToken;
	dispatch_once(&oneToken, ^{
		share = [[BYBlueTooth alloc]init];
	});
	return share;
}

-(instancetype) init {
	self = [super init];
	if (self) {
		byCentralManager = [[BYCentralManager alloc] init];
		byCallBack = [[BYCallBack alloc] init];
		byCentralManager->byCallBack = byCallBack;
	}
	return self;
}

#pragma mark - babybluetooth的委托

//设备状态改变的委托
- (void)setBlockOnCentralManagerDidUpdateStateWithKey:(NSString *)key block:(void (^)(CBCentralManager *central))block {
	[byCallBack.blocksOnCentralManagerDidUpdateState setValue:block forKey:key];
}

//找到Peripherals的委托
- (void)setBlockOnDiscoverToPeripheralsWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block {
	[byCallBack.blockOnDiscoverPeripherals setValue:block forKey:key];
}

//连接Peripherals成功的委托
- (void)setBlockOnConnectedWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block {
	[byCallBack.blockOnConnectedPeripheral setValue:block forKey:key];
}

//连接Peripherals失败的委托
- (void)setBlockOnFailToConnectWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
	[byCallBack.blockOnFailToConnect setValue:block forKey:key];
}
//断开Peripherals的连接
- (void)setBlockOnDisconnectWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
	[byCallBack.blockOnDisconnect setValue:block forKey:key];
}
//设置查找服务回叫
- (void)setBlockOnDiscoverServicesWithKey:(NSString *)key block:(void (^)(CBPeripheral *peripheral,NSError *error))block {
	[byCallBack.blockOnDiscoverServices setValue:block forKey:key];
}
//设置查找到Characteristics的block
- (void)setBlockOnDiscoverCharacteristicsWithKey:(NSString *)key block:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block {
	[byCallBack.blockOnDiscoverCharacteristics setValue:block forKey:key];
}
//设置获取到最新Characteristics值的block
- (void)setBlockOnReadValueForCharacteristicWithKey:(NSString *)key block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block {
	[byCallBack.blockOnReadValueForCharacteristic setValue:block forKey:key];
}

/**
 移除与key相关的block
 */
- (void)removeBlockWithKey:(NSString *)key {
	if(byCallBack.blocksOnCentralManagerDidUpdateState[key]) {
		[byCallBack.blocksOnCentralManagerDidUpdateState removeObjectForKey:key];
	}
	if(byCallBack.blockOnDiscoverPeripherals[key]) {
		[byCallBack.blockOnDiscoverPeripherals removeObjectForKey:key];
	}
	if(byCallBack.blockOnConnectedPeripheral[key]) {
		[byCallBack.blockOnConnectedPeripheral removeObjectForKey:key];
	}
	if(byCallBack.blockOnFailToConnect[key]) {
		[byCallBack.blockOnFailToConnect removeObjectForKey:key];
	}
	if(byCallBack.blockOnDisconnect[key]) {
		[byCallBack.blockOnDisconnect removeObjectForKey:key];
	}
	if(byCallBack.blockOnDiscoverServices[key]) {
		[byCallBack.blockOnDiscoverServices removeObjectForKey:key];
	}
	if(byCallBack.blockOnDiscoverCharacteristics[key]) {
		[byCallBack.blockOnDiscoverCharacteristics removeObjectForKey:key];
	}
	if(byCallBack.blockOnReadValueForCharacteristic[key]) {
		[byCallBack.blockOnReadValueForCharacteristic removeObjectForKey:key];
	}
	[byCallBack setFilterOnDiscoverPeripherals:nil];
	[byCallBack setFilterForServiceName:nil];
	[byCallBack setFilterForReadCharacteristicName:nil];
}


#pragma mark - 设置查找Peripherals的规则

/**
 设置查找Peripherals的规则
 */
- (void)setFilterOnDiscoverPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter {
	[byCallBack setFilterOnDiscoverPeripherals:filter];
}

#pragma mark - 设置指定的Service名称

/**
 设置指定的Service名称
 */
- (void)setFilterForServiceName:(BOOL (^)(NSString *serviceName))filter {
	[byCallBack setFilterForServiceName:filter];
}

#pragma mark - 指定用于读取数据的Characteristic名称

/**
 指定用于读取数据的Characteristic名称
 */
- (void)setFilterForCharacteristicName:(BOOL (^)(NSString *characteristicName))filter {
	[byCallBack setFilterForReadCharacteristicName:filter];
}


#pragma mark - 链式函数
//查找Peripherals
- (BYBlueTooth *(^)()) scanForPeripherals {
	return ^BYBlueTooth *() {
		[byCentralManager->pocket setObject:@"YES" forKey:@"needScanForPeripherals"];
		return self;
	};
}

//连接Peripherals
- (BYBlueTooth *(^)()) connectToPeripherals {
	return ^BYBlueTooth *() {
		[byCentralManager->pocket setObject:@"YES" forKey:@"needConnectPeripheral"];
		return self;
	};
}

//发现Services
- (BYBlueTooth *(^)()) discoverServices {
	return ^BYBlueTooth *() {
		[byCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverServices"];
		return self;
	};
}

//获取Characteristics
- (BYBlueTooth *(^)()) discoverCharacteristics {
	return ^BYBlueTooth *() {
		[byCentralManager->pocket setObject:@"YES" forKey:@"needDiscoverCharacteristics"];
		return self;
	};
}

//更新Characteristics的值
- (BYBlueTooth *(^)()) readValueForCharacteristic {
	return ^BYBlueTooth *() {
		[byCentralManager->pocket setObject:@"YES" forKey:@"needReadValueForCharacteristic"];
		return self;
	};
}


//开始并执行
- (BYBlueTooth *(^)()) begin {
	return ^BYBlueTooth *() {
		//每次begin都重置连接重试次数
		CENTRAL_MANAGER_INIT_WAIT_TIMES = 0;
		//取消未执行的stop定时任务
		[timerForStop invalidate];
		dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			//重置串行方法参数
			[self resetSeriseParmeter];
			
			//处理链式函数缓存的数据
			if ([[byCentralManager->pocket valueForKey:@"needScanForPeripherals"] isEqualToString:@"YES"]) {
				byCentralManager->needScanForPeripherals = YES;
			}
			if ([[byCentralManager->pocket valueForKey:@"needConnectPeripheral"] isEqualToString:@"YES"]) {
				byCentralManager->needConnectPeripheral = YES;
			}
			if ([[byCentralManager->pocket valueForKey:@"needDiscoverServices"] isEqualToString:@"YES"]) {
				byCentralManager->needDiscoverServices = YES;
			}
			if ([[byCentralManager->pocket valueForKey:@"needDiscoverCharacteristics"] isEqualToString:@"YES"]) {
				byCentralManager->needDiscoverCharacteristics = YES;
			}
			if ([[byCentralManager->pocket valueForKey:@"needReadValueForCharacteristic"] isEqualToString:@"YES"]) {
				byCentralManager->needReadValueForCharacteristic = YES;
			}
			
			//缓存的peripheral
			CBPeripheral *cachedPeripheral = byCentralManager->cachedPeripheral;
			//校验series合法性
			[self validateProcess];
			//清空pocjet
			byCentralManager->pocket = [[NSMutableDictionary alloc]init];
			//开始扫描或连接设备
			[self start:cachedPeripheral];
		});
		return self;
	};
}

//私有方法，扫描或使用已缓存的cachedPeripheral连接设备
- (void)start:(CBPeripheral *)cachedPeripheral {
	if (byCentralManager->centralManager.state == CBCentralManagerStatePoweredOn) {
		//扫描后连接
		if (byCentralManager->needScanForPeripherals) {
			//移除已发现的peripheral
			[byCentralManager->discoverPeripherals removeAllObjects];
			//取消连接
			if (cachedPeripheral) {
				[byCentralManager cancelPeripheralConnection:cachedPeripheral];
			}
			//开始扫描peripherals
			[byCentralManager scanPeripherals];
		}
		//直接连接
		else {
			if (cachedPeripheral) {
				[byCentralManager connectToPeripheral:cachedPeripheral];
			}
		}
		return;
	}
	//尝试重新等待CBCentralManager打开次数加1
	CENTRAL_MANAGER_INIT_WAIT_TIMES ++;
	//等待次数超过缺省设定
	if (CENTRAL_MANAGER_INIT_WAIT_TIMES >= KBY_CENTRAL_MANAGER_INIT_WAIT_TIMES ) {
		BYLog(@">>> 第%d次等待CBCentralManager 打开任然失败，请检查你蓝牙使用权限或检查设备问题。",CENTRAL_MANAGER_INIT_WAIT_TIMES);
		return;
		//[NSException raise:@"CBCentralManager打开异常" format:@"尝试等待打开CBCentralManager5次，但任未能打开"];
	}
	//KBY_CENTRAL_MANAGER_INIT_WAIT_SECOND秒后重新执行函数
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, KBY_CENTRAL_MANAGER_INIT_WAIT_SECOND * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self start:cachedPeripheral];
	});
	BYLog(@">>> 第%d次等待CBCentralManager打开",CENTRAL_MANAGER_INIT_WAIT_TIMES);
}


//重置串行方法参数，防止多次调用begin使用同样的参数
- (void)resetSeriseParmeter {
	byCentralManager->needScanForPeripherals = NO;
	byCentralManager->needConnectPeripheral = NO;
	byCentralManager->needDiscoverServices = NO;
	byCentralManager->needDiscoverCharacteristics = NO;
	byCentralManager->needReadValueForCharacteristic = NO;
}

- (void)validateProcess {
	
	NSMutableArray *faildReason = [[NSMutableArray alloc]init];
	
	//规则：不执行discoverCharacteristics()时，不能执行readValueForCharacteristic()
	if (!byCentralManager->needDiscoverCharacteristics) {
		if (byCentralManager->needReadValueForCharacteristic) {
			[faildReason addObject:@"未执行discoverCharacteristics()不能执行readValueForCharacteristic()"];
		}
	}
	
	//规则： 不执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()
	if (!byCentralManager->needDiscoverServices) {
		if (byCentralManager->needDiscoverCharacteristics||byCentralManager->needReadValueForCharacteristic) {
			[faildReason addObject:@"未执行discoverServices()不能执行discoverCharacteristics()、readValueForCharacteristic()"];
		}
		
	}
	
	//规则：不执行connectToPeripherals()时，不能执行discoverServices()
	if(!byCentralManager->needConnectPeripheral) {
		if (byCentralManager->needDiscoverServices) {
			[faildReason addObject:@"未执行connectToPeripherals()不能执行discoverServices()"];
		}
	}
	
	//规则：不执行needScanForPeripherals()，那么执行connectToPeripheral()方法时必须用having(peripheral)传入peripheral实例
	if (!byCentralManager->needScanForPeripherals) {
		CBPeripheral *peripheral = byCentralManager->cachedPeripheral;
		if (!peripheral) {
			[faildReason addObject:@"若不执行scanForPeripherals()方法，则必须执行having(peripheral)方法并且需要传入参数(CBPeripheral *)peripheral"];
		}
	}
	
	//抛出异常
	if ([faildReason lastObject]) {
		NSException *e = [NSException exceptionWithName:@"BYBluetooth usage exception" reason:[faildReason lastObject]  userInfo:nil];
		@throw e;
	}
	
}

//sec秒后没有连接成功则断开
- (BYBlueTooth *(^)(int sec)) stop {
	
	return ^BYBlueTooth *(int sec) {
		BYLog(@">>> stop in %d sec",sec);
		timerForStop = [NSTimer timerWithTimeInterval:sec target:self selector:@selector(byStop) userInfo:nil repeats:NO];
		[timerForStop setFireDate: [[NSDate date]dateByAddingTimeInterval:sec]];
		[[NSRunLoop currentRunLoop] addTimer:timerForStop forMode:NSRunLoopCommonModes];
		
		return self;
	};
}

//私有方法，停止扫描和断开连接，清空pocket
- (void)byStop {
	//如果时间到达后仍未成功连接
	if(!byCentralManager->connectedPeripheral) {
		BYLog(@">>>did stop");
		[timerForStop invalidate];
		[self resetSeriseParmeter];
		byCentralManager->pocket = [[NSMutableDictionary alloc]init];
		//停止扫描，断开连接
		[byCentralManager cancelScan];
		if(byCentralManager->cachedPeripheral) {
			[byCentralManager cancelPeripheralConnection:byCentralManager->cachedPeripheral];
		}
	}
}

//持有对象
- (BYBlueTooth *(^)(id obj)) having {
	return ^(id obj) {
		byCentralManager->cachedPeripheral = obj;
		return self;
	};
}

- (BYBlueTooth *) and {
	return self;
}

- (BYBlueTooth *) then {
	return self;
}

- (BYBlueTooth *) with {
	return self;
}

- (BYBlueTooth *(^)()) enjoy {
	return ^BYBlueTooth *(int sec) {
		self.connectToPeripherals().discoverServices().discoverCharacteristics()
		.readValueForCharacteristic();
		return self;
	};
}

#pragma mark - 工具方法
//断开连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
	[byCentralManager cancelPeripheralConnection:peripheral];
}
//停止扫描
- (void)cancelScan{
	[byCentralManager cancelScan];
}

@end
