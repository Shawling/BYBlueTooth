//
//  BYTools.h
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/30.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYTools : NSObject

/**
 将传入的NSString类型转换成NSData并返回，16进制
 */
+(NSData*)dataWithHexstring:(NSString *)hexstring;

/**
 将传入的NSData类型转换成NSString并返回，16进制
 */
+(NSString*)hexadecimalString:(NSData *)data;

/**
 计算校验和
 */
+(NSString*)getSumByHex:(NSString*)hex;

/**
 普通ASCII字符串转换为十六进制字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string;


@end
