//
//  BYLocationModel.h
//  BYBlueTooth
//
//  Created by Darin4lin on 2017/4/6.
//  Copyright © 2017年 QZBD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYLocationModel : NSObject
/** 定位模式,GP: 单GPS定位,BD: 单北斗定位,GL: 单GLONASS定位,GN: 混合系统定位 */
@property NSString *mode;
/** 定位时间，格式hhmmss.ss */
@property NSString *time;
/** 纬度格式为度分，前2个数字为度，后面的数字为分 */
@property double latitude;
/** 纬度方向 */
@property NSString *latitudeTarget;
/** 经度格式为度分，前3个数字为度，后面的数字为分 */
@property double longitude;
/** 经度方向 */
@property NSString *longitudeTarget;
/** 定位状态,0-无效解，1-单点定位，2-伪距差分，4-固定解，5-浮点解 */
@property int status;
/** 参与定位解算的卫星数 */
@property int starNum;
/** 水平位置精度因子 */
@property double precisionFactor;
/** 天线海拔高度 */
@property double antennaAltitude;
/** 海拔高度的单位 */
@property NSString *altitudeUnit;
/** 高程异常值 */
@property double heightAnomalyValue;
/** 高程异常值的单位的单位 */
@property NSString *heightAnomalyUnit;
/** 差分延迟 */
@property double differentialDelay;
/** 差分站台ID号 */
@property int differentialPlatformID;
/** VDOP值 */
@property double vdopValue;

@end
