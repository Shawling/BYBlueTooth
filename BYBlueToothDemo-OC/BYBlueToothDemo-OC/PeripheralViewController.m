//
//  PeripheralViewController.m
//  BYBlueToothDemo-OC
//
//  Created by Darin4lin on 2017/3/27.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import "PeripheralViewController.h"
#import "Define.h"

@interface PeripheralViewController ()

@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setTitle:_currPeripheral.name];
	
	//开始连接设备
	[SVProgressHUD showInfoWithStatus:@"开始连接设备"];
	[self babyDelegate];
	//设置超时10秒，10秒后没有连接成功则断开
	bb.having(_currPeripheral).enjoy().begin().stop(10);
}

//页面销毁后必须调用removeBlockWithKey移除蓝牙委托
- (void)dealloc {
	[bb removeBlockWithKey:CLASS_KEY];
}

-(void)babyDelegate {
	__weak typeof(self)weakSelf = self;
	
	//设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
	[bb setBlockOnConnectedWithKey:CLASS_KEY block:^(CBCentralManager *central, CBPeripheral *peripheral) {
		[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
	}];
	
	//设置重新连接，也是在断开连接委托中，如果有错误信息，可以判断出不是手动断开连接
	[bb setBlockOnDisconnectWithKey:CLASS_KEY block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
		__typeof__(self) strongSelf = weakSelf;
		NSString *str;
		
		if(error) {
			//异常断开，需要重连
			str = [NSString stringWithFormat:@"%@断开连接，准备重连，错误信息%@", [peripheral name], [error localizedDescription]];
			[SVProgressHUD showWithStatus:str];
			
			//重新连接
			//需要重新设置委托
			[weakSelf babyDelegate];
			//设置超时10秒，10秒后没有连接成功则断开
			strongSelf->bb.having([strongSelf currPeripheral]).enjoy().begin().stop(10);
		} else {
			//手动断开，自行处理
			str = [NSString stringWithFormat:@"%@断开连接", [peripheral name]];
			[SVProgressHUD showInfoWithStatus:str];
			[weakSelf.navigationController popViewControllerAnimated:YES];
		}
	}];
}

- (IBAction)cancleConnectTap:(id)sender {
	//取消连接，在setBlockOnDisconnectWithKey委托中处理断开成功后的操作
	[bb cancelPeripheralConnection:_currPeripheral];
}

@end
