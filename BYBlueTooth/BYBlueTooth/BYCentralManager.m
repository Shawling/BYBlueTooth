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
        
        
//#if  __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_6_0
//        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 //蓝牙power没打开时alert提示框
//                                 [NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey,
//                                 //重设centralManager恢复的IdentifierKey
//                                 @"byBluetoothRestore",CBCentralManagerOptionRestoreIdentifierKey,
//                                 nil];
//        
//#else
//        NSDictionary *options = nil;
//#endif
//        
//        NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"UIBackgroundModes"];
//        if ([backgroundModes containsObject:@"bluetooth-central"]) {
//            //后台模式
//            _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:options];
//        }
//        else {
//            //非后台模式
//            _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
//        }
        
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        
        pocket = [[NSMutableDictionary alloc]init];
        discoverPeripherals = [[NSMutableArray alloc]init];
        reConnectPeripherals = [[NSMutableArray alloc]init];
        cachedZDXX = [@"" mutableCopy];
    }
    return  self;
    
}

#pragma mark - 接收到通知

//扫描Peripherals
- (void)scanPeripherals {
    if(self->needSearchService) {
        NSMutableArray<CBUUID *> *arr = [[NSMutableArray alloc]init];
        for (NSString *uuid in self->needSearchService) {
            [arr addObject:[CBUUID UUIDWithString:uuid]];
        }
        [_centralManager scanForPeripheralsWithServices:arr options:nil];
    } else {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

//连接Peripherals
- (void)connectToPeripheral:(CBPeripheral *)peripheral{
    [_centralManager connectPeripheral:peripheral options:nil];
}

//断开设备连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral {
    [_centralManager cancelPeripheralConnection:peripheral];
}

//停止扫描
- (void)cancelScan {
    [_centralManager stopScan];
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
    BYLog(@">>>扫描到设备:%@",peripheral.name);
    
    if ([self addDiscoverPeripheral:peripheral]) {
        //扫描到设备callback
        if ([byCallBack filterOnDiscoverPeripherals]) {
            if ([byCallBack filterOnDiscoverPeripherals](peripheral.name,advertisementData,RSSI)) {
                if ([byCallBack blockOnDiscoverPeripherals]) {
                    for (NSString *key in byCallBack.blockOnDiscoverPeripherals) {
                        byCallBack.blockOnDiscoverPeripherals[key](central,peripheral,advertisementData,RSSI);
                    }
                }
            }
        } else {
            if ([byCallBack blockOnDiscoverPeripherals]) {
                for (NSString *key in byCallBack.blockOnDiscoverPeripherals) {
                    byCallBack.blockOnDiscoverPeripherals[key](central,peripheral,advertisementData,RSSI);
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
    self->writeCharacteristic = nil;
    if ([byCallBack blockOnDisconnect]) {
        for (NSString *key in byCallBack.blockOnDisconnect) {
            byCallBack.blockOnDisconnect[key](central,peripheral,error);
        }
    }
}

//扫描到服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    BYLog(@">>>扫描到服务：%@",peripheral.services);
    for (CBService *service in peripheral.services) {
        BYLog(@">>>服务的UUIDString：%@",service.UUID.UUIDString);
    }
    if (error) {
        BYLog(@">>>didDiscoverServices for %@ with error: %@", peripheral.name, [error localizedDescription]);
    }
    
    //回叫block
    if ([byCallBack blockOnDiscoverServices]) {
        for (NSString *key in byCallBack.blockOnDiscoverServices) {
            byCallBack.blockOnDiscoverServices[key](peripheral,error);
        }
    }
    
    //discover characteristics
    if (needDiscoverCharacteristics) {
        //如果设置了characteristics所在的service
        if ([byCallBack filterForServiceName]) {
            for (CBService *service in peripheral.services) {
                if ([byCallBack filterForServiceName](service.UUID.UUIDString)) {
                    [peripheral discoverCharacteristics:nil forService:service];
                }
            }
        } else {
            for (CBService *service in peripheral.services) {
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

//发现服务的Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    BYLog(@">>>扫描到服务%@的Characteristics：%@", service.UUID, service.characteristics);
    if (error) {
        BYLog(@"error didDiscoverCharacteristicsForService for %@ with error: %@", service.UUID, [error localizedDescription]);
    }
    
    //如果需要更新Characteristic的值
    if (needReadValueForCharacteristic) {
        //如果设置了读取数据characteristics的名称
        if ([byCallBack filterForReadCharacteristicName]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([byCallBack filterForReadCharacteristicName](characteristic.UUID.UUIDString)) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        } else {
            for (CBCharacteristic *characteristic in service.characteristics) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    }
    
    //如果设置了写入数据characteristics的名称
    if ([byCallBack filterForWriteCharacteristicName]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([byCallBack filterForWriteCharacteristicName](characteristic.UUID.UUIDString)) {
                self->writeCharacteristic = characteristic;
                break;
            }
        }
    }
    
    //回叫block
    if ([byCallBack blockOnDiscoverCharacteristics]) {
        NSDictionary<NSString *, BYDiscoverCharacteristicsBlock> *b = [NSDictionary dictionaryWithDictionary:[byCallBack blockOnDiscoverCharacteristics]];
        for (NSString *key in b) {
            b[key](peripheral,service,error);
        }
    }
}

//读取Characteristics的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    BYLog(@">>>读取到来自%@的数据：%@", characteristic.UUID, characteristic.value);
    
    if (error) {
        BYLog(@"error didUpdateValueForCharacteristic %@ with error: %@", characteristic.UUID, [error localizedDescription]);
    }
    
    //回叫读取数据block
    if ([byCallBack blockOnReadValueForCharacteristic]) {
        for (NSString *key in byCallBack.blockOnReadValueForCharacteristic) {
            byCallBack.blockOnReadValueForCharacteristic[key](peripheral,characteristic,error);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    if(error) {
        BYLog(@"error didWriteValueForCharacteristic %@ with error: %@", characteristic.UUID, [error localizedDescription]);
    }
    else {
        BYLog(@">>>向%@写入数据成功", characteristic.UUID);
    }
}

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
//
//}


#pragma mark - 私有方法	- 设备list管理

- (BOOL)addDiscoverPeripheral:(CBPeripheral *)peripheral{
    if (![discoverPeripherals containsObject:peripheral]) {
        [discoverPeripherals addObject:peripheral];
        return YES;
    }
    return NO;
}

@end
