//
//  ViewController.m
//  BYBlueToothDemo-OC
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import "ViewController.h"
#import <BYBlueTooth/BYBlueTooth.h>
#import "Define.h"

@interface ViewController () {
	BYBlueTooth *bb;
	NSMutableArray *peripheralArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	peripheralArray = [[NSMutableArray alloc]init];
	
	bb = [BYBlueTooth shareBYBlueTooth];
}

//页面销毁后必须调用removeBlockWithKey移除蓝牙委托
- (void)dealloc {
	[bb removeBlockWithKey:CLASS_KEY];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//开始扫描设备
	[self performSelector:@selector(refreshPeripheral) withObject:nil afterDelay:1];
}

-(void)babyDelegate{
	__weak typeof(self) weakSelf = self;
	
	//设置蓝牙状态响应回调
	[bb setBlockOnCentralManagerDidUpdateStateWithKey:CLASS_KEY block:^(CBCentralManager *central) {
		switch(central.state) {
			case CBManagerStatePoweredOn:
				[SVProgressHUD showInfoWithStatus:@"蓝牙已打开"];
				[weakSelf refreshPeripheral];
				break;
			case CBManagerStatePoweredOff:
				[SVProgressHUD showInfoWithStatus:@"蓝牙已关闭"];
				break;
			case CBCentralManagerStateUnsupported:
				[SVProgressHUD showErrorWithStatus:@"蓝牙不支持"];
				break;
			default:
				break;
		}
	}];
	
	//设置查找设备的过滤器
	[bb setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
		//设置查找规则是名称大于0
		if (peripheralName.length >0) {
			return YES;
		}
		return NO;
	}];
	
	//设置扫描到设备的委托
	[bb setBlockOnDiscoverToPeripheralsWithKey:CLASS_KEY block:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
		[weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
	}];
}

- (IBAction)reFreshTap:(UIBarButtonItem *)sender {
	[self refreshPeripheral];
}

-(void)refreshPeripheral {
	[SVProgressHUD showInfoWithStatus:@"正在扫描设备"];
	[peripheralArray removeAllObjects];
	[_tableView reloadData];
	
	//设置蓝牙委托
	[self babyDelegate];
	//开始扫描
	bb.scanForPeripherals().begin();
}

#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
	NSArray *peripherals = [peripheralArray valueForKey:@"peripheral"];
	if(![peripherals containsObject:peripheral]) {
		NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripheralArray.count inSection:0];
		[indexPaths addObject:indexPath];
		
		NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
		[item setValue:peripheral forKey:@"peripheral"];
		[item setValue:advertisementData forKey:@"advertisementData"];
		[peripheralArray addObject:item];
		
		[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark -table委托 table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return peripheralArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
	NSDictionary *item = [peripheralArray objectAtIndex:indexPath.row];
	CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
	NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
	
	if (!cell) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	//peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name, 还是没有就用identifier
	NSString *peripheralName;
	if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
		peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
	}else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
		peripheralName = peripheral.name;
	}else{
		peripheralName = [peripheral.identifier UUIDString];
	}
	
	cell.textLabel.text = peripheralName;
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	//停止扫描
	[bb cancelScan];
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
	PeripheralViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PeripheralViewController"];
	NSDictionary *item = [peripheralArray objectAtIndex:indexPath.row];
	CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
	vc.currPeripheral = peripheral;
	vc->bb = self->bb;
	[self.navigationController pushViewController:vc animated:YES];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
