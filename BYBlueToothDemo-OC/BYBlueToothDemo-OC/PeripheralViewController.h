//
//  PeripheralViewController.h
//  BYBlueToothDemo-OC
//
//  Created by Darin4lin on 2017/3/27.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BYBlueTooth/BYBlueTooth.h>
#import "SVProgressHUD.h"

@interface PeripheralViewController : UIViewController{
@public
	BYBlueTooth *bb;
}

@property(strong,nonatomic) CBPeripheral *currPeripheral;

@end
