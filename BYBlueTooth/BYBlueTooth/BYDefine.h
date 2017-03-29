//
//  BYDefine.h	预定义SDK的一些配置
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <Foundation/Foundation.h>

# pragma mark - 行为定义

//if show log 是否打印日志，默认1：打印 ，0：不打印
#define KBY_IS_SHOW_LOG 1

//CBcentralManager等待设备打开计时次数
# define KBY_CENTRAL_MANAGER_INIT_WAIT_TIMES 5

//CBcentralManager等待设备打开计时间隔时间
# define KBY_CENTRAL_MANAGER_INIT_WAIT_SECOND 2.0

#ifdef DEBUG
//BYLog
#define BYLog(fmt, ...) if(KBY_IS_SHOW_LOG) { NSLog(@"[BYBlueTooth] " fmt,##__VA_ARGS__); }
#else
// 定义是输出Log
#define BYLog(fmt, ...)
#endif

