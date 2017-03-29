//
//  BYCallBack.h	保存设置的所有回调Block
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark - 定义Block
//设备状态改变的委托
typedef void (^BYCentralManagerDidUpdateStateBlock)(CBCentralManager *central);
//找到设备的委托
typedef void (^BYDiscoverPeripheralsBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI);
//连接设备成功的block
typedef void (^BYConnectedPeripheralBlock)(CBCentralManager *central,CBPeripheral *peripheral);
//连接设备失败的block
typedef void (^BYFailToConnectBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error);
//断开设备连接的bock
typedef void (^BYDisconnectBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error);
//找到服务的block
typedef void (^BYDiscoverServicesBlock)(CBPeripheral *peripheral,NSError *error);
//找到Characteristics的block
typedef void (^BYDiscoverCharacteristicsBlock)(CBPeripheral *peripheral,CBService *service,NSError *error);
//更新（获取）Characteristics的value的block
typedef void (^BYReadValueForCharacteristicBlock)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error);

@interface BYCallBack : NSObject


#pragma mark - 存放Block的字典
//设备状态改变的委托列表
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYCentralManagerDidUpdateStateBlock>* blocksOnCentralManagerDidUpdateState;
//发现peripherals
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYDiscoverPeripheralsBlock>* blockOnDiscoverPeripherals;
//连接peripherals
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYConnectedPeripheralBlock>* blockOnConnectedPeripheral;
//连接设备失败的block
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYFailToConnectBlock>* blockOnFailToConnect;
//断开设备连接的bock
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYDisconnectBlock>* blockOnDisconnect;
//发现services
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYDiscoverServicesBlock>* blockOnDiscoverServices;
//发现Characteristics
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYDiscoverCharacteristicsBlock>* blockOnDiscoverCharacteristics;
//更新Characteristics的value
@property (nonatomic, copy) NSMutableDictionary<NSString *, BYReadValueForCharacteristicBlock>* blockOnReadValueForCharacteristic;


#pragma mark - 工具方法
//发现peripherals规则
@property (nonatomic, copy) BOOL (^filterOnDiscoverPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
//设置指定的Service名称
@property (nonatomic, copy) BOOL (^filterForServiceName)(NSString *serviceName);
//设置指定的Characteristic名称
@property (nonatomic, copy) BOOL (^filterForReadCharacteristicName)(NSString *characteristicName);

@end
