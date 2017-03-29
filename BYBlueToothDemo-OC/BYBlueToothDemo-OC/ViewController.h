//
//  ViewController.h
//  BYBlueToothDemo-OC
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralViewController.h"
#import "SVProgressHUD.h"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

