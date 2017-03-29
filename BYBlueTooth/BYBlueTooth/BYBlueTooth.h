//
//  BYBlueTooth.h	SDK外部使用接口
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BYBlueTooth : NSObject

#pragma mark - babybluetooth的委托

/**
 设备状态改变的block |  when CentralManager state changed
 */
- (void)setBlockOnCentralManagerDidUpdateStateWithKey:(NSString *)key block:(void (^)(CBCentralManager *central))block;

/**
 找到Peripherals的block |  when find peripheral
 */
- (void)setBlockOnDiscoverToPeripheralsWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block;

/**
 连接Peripherals成功的block
 |  when connected peripheral
 */
- (void)setBlockOnConnectedWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral))block;

/**
 连接Peripherals失败的block
|  when fail to connect peripheral
*/
- (void)setBlockOnFailToConnectWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block;

/**
 断开Peripherals的连接的block
 |  when disconnected peripheral
 */
- (void)setBlockOnDisconnectWithKey:(NSString *)key block:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block;

/**
 设置查找服务的block
 |  when discover services of peripheral
 */
- (void)setBlockOnDiscoverServicesWithKey:(NSString *)key block:(void (^)(CBPeripheral *peripheral,NSError *error))block;

/**
 设置查找到Characteristics的block
 |  when discovered Characteristics
 */
- (void)setBlockOnDiscoverCharacteristicsWithKey:(NSString *)key block:(void (^)(CBPeripheral *peripheral,CBService *service,NSError *error))block;

/**
 设置获取到最新Characteristics值的block
 |  when read new characteristics value  or notiy a characteristics value
 */
- (void)setBlockOnReadValueForCharacteristicWithKey:(NSString *)key block:(void (^)(CBPeripheral *peripheral,CBCharacteristic *characteristic,NSError *error))block;

/**
 移除所有与key相关的block
 */
- (void)removeBlockWithKey:(NSString *)key;


#pragma mark - 设置查找Peripherals的规则

/**
 设置查找Peripherals的规则
 |  filter of discover peripherals
 */
- (void)setFilterOnDiscoverPeripherals:(BOOL (^)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI))filter;

#pragma mark - 设置指定的Service名称

/**
 设置指定的Service名称
 */
- (void)setFilterForServiceName:(BOOL (^)(NSString *serviceName))filter;


#pragma mark - 链式函数

/**
 查找Peripherals
 */
- (BYBlueTooth *(^)()) scanForPeripherals;

/**
 开始执行
 */
- (BYBlueTooth *(^)()) begin;

/**
 sec秒后没有连接成功则断开
 */
- (BYBlueTooth *(^)(int sec)) stop;

/**
 持有对象
 */
- (BYBlueTooth *(^)(id obj)) having;

/**
 * enjoy 完成一整套蓝牙流程，调用此方法前前面必须有scanForPeripherals或having方法，之后再调用begin方法，祝你使用愉快
 */

- (BYBlueTooth *(^)()) enjoy;

#pragma mark - 工具方法

/**
 * 单例构造方法
 * @return BabyBluetooth共享实例
 */
+ (instancetype)shareBYBlueTooth;

/**
 断开连接
 */
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;

/**
 停止扫描
 */
- (void)cancelScan;

@end
