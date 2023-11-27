//
//  BGDeviceInfor.h
//
//  Created by BG on 2019/5/10.
//  Copyright © 2019年 BG All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BGDeviceInfor : NSObject

// 1.获取设备名称 user-assigned device name (e.g. @"My iPhone").
+ (NSString *)getDeviceName;
// 获取手机名称 iPhone
+ (NSString *)getDeviceModel;
//获取os_version 16.2
+ (NSString *)getOs_version;
//** 获取设备型号 */ x86_64 iPhone9,1
+ (NSString *)deviceCode;
// 获取内存大小
+ (NSString *)totalMemorySize;
//获取App版本信息
+ (NSString *)appBundleId;
+ (NSString *)appVersion;
+ (NSString *)appBuildVersion;
+ (NSString *)appName;

+ (NSString *)clientTime;
//获取屏幕的分辨率
+ (CGSize)getPhoneSize;
//获取运营商
+ (NSString *)getCurrentOperator;

/** 获取当前网络 */
+ (NSString *)getCurrentNerWork;

// 获取user_agent
+ (NSString *)getUser_agnet;

// 获取IDFV的方法
+ (NSString *)getIDFV;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
