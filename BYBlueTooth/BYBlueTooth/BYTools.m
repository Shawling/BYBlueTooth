//
//  NSObject+BYTools.m
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/3/30.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import "BYTools.h"

@implementation BYTools

#pragma mark - 将传入的NSString类型转换成NSData并返回
+ (NSData*)dataWithHexstring:(NSString *)hexstring{
	
	NSMutableData *data = [NSMutableData data];
	int idx;
	for(idx            = 0; idx + 2 <= hexstring.length; idx += 2){
		NSRange range      = NSMakeRange(idx, 2);
		NSString* hexStr   = [hexstring substringWithRange:range];
		NSScanner* scanner = [NSScanner scannerWithString:hexStr];
		unsigned int intValue;
		[scanner scanHexInt:&intValue];
		[data appendBytes:&intValue length:1];
	}
	
	return data;
}

#pragma mark - 将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data{
	NSString* result;
	const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
	if(!dataBuffer){
		return nil;
	}
	NSUInteger dataLength      = [data length];
	NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
	for(int i                  = 0; i < dataLength; i++){
		[hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
	}
	result = [NSString stringWithString:hexString];
	return result;
}

#pragma mark - 计算校验和
+(NSString*)getSumByHex:(NSString*)hex {
	
	unsigned long sum = 0;
	
	NSRange range  = {0,2};
	NSString *aSub = [hex substringWithRange:range];
	
	for (int i = 0; i < [hex length] / 2 - 1; i++) {
		
		NSRange range1 = {2 * (i + 1),2};
		NSString *bSub = [hex substringWithRange:range1];
		
		sum = strtoul([aSub UTF8String],0,16) ^ strtoul([bSub UTF8String],0,16);
		//        NSLog(@"i = %d\naSub --> %@\naSub --> %@\nsum -->  %@",i,[self getBinaryByhex:aSub],[self getBinaryByhex:bSub],[self getBinaryByhex:[NSString stringWithFormat:@"%lx",sum]]);
		
		aSub = [NSString stringWithFormat:@"%lx",sum];
	}
	
	aSub = [NSString stringWithFormat:@"00%lx",sum];
	aSub = [aSub substringWithRange:NSMakeRange(aSub.length - 2, 2)];
	//    [NSString stringWithFormat:@"%lx",sum]
	return aSub;
}

#pragma mark - 普通ASCII字符串转换为十六进制字符串
+ (NSString *)hexStringFromString:(NSString *)string{
	NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
	Byte *bytes = (Byte *)[myD bytes];
	//下面是Byte 转换为16进制。
	NSString *hexStr=@"";
	for(int i=0;i<[myD length];i++)
		
	{
		NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
		
		if([newHexStr length]==1)
   
			hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
		
		else
   
			hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
	}
	return hexStr;
}

@end
