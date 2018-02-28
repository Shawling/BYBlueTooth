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

@interface PeripheralViewController : UIViewController<UITextFieldDelegate>{
@public
	BYBlueTooth *bb;
}

@property(strong,nonatomic) CBPeripheral *currPeripheral;

@property (weak, nonatomic) IBOutlet UITextField *input;

@property (weak, nonatomic) IBOutlet UITextField *inputHex;

@property (weak, nonatomic) IBOutlet UITextView *outPut;

@end
