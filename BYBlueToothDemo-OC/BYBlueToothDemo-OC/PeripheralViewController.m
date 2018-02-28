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
	[SVProgressHUD showWithStatus:@"开始连接设备"];
	//连接设备
	[self reConnectPeripheral];
}

//页面销毁后必须调用removeBlockWithKey移除蓝牙委托
- (void)dealloc {
	[bb removeBlockWithKey:CLASS_KEY];
}

//连接设备
-(void)reConnectPeripheral {
	[self babyDelegate];
	//设置超时10秒，10秒后没有连接成功则断开
	bb.having(_currPeripheral).enjoy().begin().stop(10);
}

-(void)babyDelegate {
	__weak typeof(self)weakSelf = self;
	
	//设置设备连接成功的委托
	[bb setBlockOnConnectedWithKey:CLASS_KEY block:^(CBCentralManager *central, CBPeripheral *peripheral) {
		[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
	}];
	
	//设置重新连接，也是在断开连接委托中，如果有错误信息，可以判断出不是手动断开连接
	[bb setBlockOnDisconnectWithKey:CLASS_KEY block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
		NSString *str;
		
		if(error) {
			//异常断开，需要重连
			str = [NSString stringWithFormat:@"%@断开连接，准备重连，错误信息%@", [peripheral name], [error localizedDescription]];
			[SVProgressHUD showWithStatus:str];
			
			//重新连接
			[weakSelf reConnectPeripheral];
		} else {
			//手动断开，自行处理
			str = [NSString stringWithFormat:@"%@断开连接", [peripheral name]];
			[SVProgressHUD showInfoWithStatus:str];
			[weakSelf.navigationController popViewControllerAnimated:YES];
		}
	}];
	
//	//设置指定的Service名称
//	[bb setFilterForServiceName:^BOOL(NSString *serviceName) {
//		if([serviceName isEqual: @"FFF0"]) {
//			return YES;
//		}
//		return NO;
//	}];
//	
//	//设定指定读取数据的Characteristic名称
//	[bb setFilterForReadCharacteristicName:^BOOL(NSString *characteristicName) {
//		if([characteristicName isEqual: @"FFE1"]) {
//			return YES;
//		}
//		return NO;
//	}];
//	
//	//设定指定写入数据的Characteristic名称，如果调用writeToPeripheral写入数据，则必须实现此函数
//	[bb setFilterForWriteCharacteristicName:^BOOL(NSString *characteristicName) {
//		if([characteristicName isEqual: @"FFE1"]) {
//			return YES;
//		}
//		return NO;
//	}];
	
}

- (IBAction)cancleConnectTap:(id)sender {
	//取消连接，在setBlockOnDisconnectWithKey委托中处理断开成功后的操作
	[bb cancelPeripheralConnection:_currPeripheral];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField; {
	if([textField isEqual:_input]) {
		[bb writeToPeripheralWithASCIIString:textField.text];
		[self.view endEditing:YES];
	} else if([textField isEqual:_inputHex]) {
		[bb writeToPeripheralWithHEXString:textField.text];
		[self.view endEditing:YES];
	}
	return YES;
}

- (IBAction)corsLoginTap:(id)sender {
	 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"CORS登录" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		NSArray<UITextField *> *textFields = alertController.textFields;
		[bb corsLoginWithip:textFields[0].text port:textFields[1].text user:textFields[2].text password:textFields[3].text mount:textFields[4].text];
	}]];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"输入ip";
	}];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"输入端口";
	}];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"输入用户名";
	}];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"输入密码";
	}];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.placeholder = @"输入挂接点";
	}];
	[self presentViewController:alertController animated:YES completion:nil];
}


@end
