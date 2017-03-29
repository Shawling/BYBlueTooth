//
//  BYCallBack.m
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import "BYCallBack.h"

@implementation BYCallBack

- (instancetype)init {
	self = [super init];
	if (self) {
		_blocksOnCentralManagerDidUpdateState = [[NSMutableDictionary alloc] init];
		_blockOnDiscoverPeripherals = [[NSMutableDictionary alloc] init];
		_blockOnConnectedPeripheral = [[NSMutableDictionary alloc] init];
		_blockOnFailToConnect = [[NSMutableDictionary alloc] init];
		_blockOnDisconnect = [[NSMutableDictionary alloc] init];
		_blockOnDiscoverServices = [[NSMutableDictionary alloc] init];
		_blockOnDiscoverCharacteristics = [[NSMutableDictionary alloc] init];
		_blockOnReadValueForCharacteristic = [[NSMutableDictionary alloc] init];
	}
	return self;
}

@end
