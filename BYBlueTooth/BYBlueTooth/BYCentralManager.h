//
//  BYCentralManager.h	蓝牙中心模式实现类
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BYDefine.h"
#import "BYCallBack.h"
#import "BYTools.h"


@interface BYCentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate> {
	
@public
	//串行方法参数，用于蓝牙模块运行时判断
	BOOL needScanForPeripherals;//是否扫描Peripherals
	BOOL needConnectPeripheral;//是否连接Peripherals
	BOOL needDiscoverServices;//是否发现Services
	BOOL needDiscoverCharacteristics;//是否获取Characteristics
	BOOL needReadValueForCharacteristic;//是否获取（更新）Characteristics的值
	//是否一次性处理
	BOOL oneReadValueForCharacteristicValue;
    
    NSArray<NSString *> *needSearchService;
	
	//方法执行时间
	int executeTime;
	
	//连接外设计时器，超时则取消任务
	NSTimer *connectTimer;
	
	//主设备
//	CBCentralManager *centralManager;
	
	//保存串行方法参数，可以在蓝牙运行时配置begin模式，而不干扰已在运行的串行方法参数
	NSMutableDictionary *pocket;
	
	//缓存的外设
	CBPeripheral *cachedPeripheral;
	//已经连接的设备
	CBPeripheral *connectedPeripheral;
	
	//用于写入数据的Characteristic
	CBCharacteristic *writeCharacteristic;
	
	//回调方法
	BYCallBack* byCallBack;

	//已经搜索到的设备
	NSMutableArray *discoverPeripherals;
	//需要自动重连的外设
	NSMutableArray *reConnectPeripherals;
	
	//已缓存的终端信息
	NSMutableString *cachedZDXX;
}

//主设备
@property (strong, nonatomic) CBCentralManager *centralManager;

//扫描Peripherals
- (void)scanPeripherals;
//连接Peripherals
- (void)connectToPeripheral:(CBPeripheral *)peripheral;
//断开设备连接
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;
//停止扫描
- (void)cancelScan;


@end
