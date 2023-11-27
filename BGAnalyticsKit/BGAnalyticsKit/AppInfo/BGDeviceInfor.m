//
//  BGDeviceInfor.m
//
//  Created by BG on 2019/5/10.
//  Copyright © 2019年 BG All rights reserved.
//

#import "BGDeviceInfor.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>
#import <AdSupport/ASIdentifierManager.h> //idfa
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <WebKit/WebKit.h>
#import "BGReachability.h"

#include <net/if.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation BGDeviceInfor

static WKWebView* webView;

// 1.获取设备名称
+ (NSString *)getDeviceName {
    NSString *strName = [[UIDevice currentDevice] name];
    return strName;
}

+ (NSString *)deviceCode {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return platform;
}

+ (NSString *)getOs_version {
    return  [[UIDevice currentDevice] systemVersion];
}

// 获取手机名称
+ (NSString *)getDeviceModel {
    NSString *phoneName = [[UIDevice currentDevice] model];
    return phoneName;
}

// 获取内存大小
+ (NSString *)totalMemorySize {
    long long physicalMemory = [NSProcessInfo processInfo].physicalMemory;
    long long physicalMemoryKb = physicalMemory/(1024*1024);
    NSString *physicalMemoryStr = [NSString stringWithFormat:@"%lldM", physicalMemoryKb];
    return physicalMemoryStr;
}

//获取App版本信息
+ (NSString *)appBundleId {
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [plistDic objectForKey:@"CFBundleIdentifier"];
    return version;
}

+ (NSString *)appVersion {
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [plistDic objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)appBuildVersion {
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString *plistBuild = [plistDic objectForKey:@"CFBundleVersion"];
    return plistBuild;
}

+ (NSString *)appName {
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = [plistDic objectForKey:@"CFBundleDisplayName"];
    if (!displayName || displayName.length <= 0) {
        displayName = [plistDic objectForKey:@"CFBundleName"];
    }
    return displayName;
}

+ (NSString *)clientTime {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", (double)[datenow timeIntervalSince1970]];
    return timeSp;
}

//获取IDFV
+ (NSString *)getIDFV {
    NSString * strUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (!strUUID || [strUUID isEqualToString:@""]){
        return @"";
    }
    return strUUID;
}

//获取屏幕的分辨率
+ (CGSize)getPhoneSize {
    //    1、得到当前屏幕的尺寸：
    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    CGSize size_screen = rect_screen.size;
    //    2、获得scale：
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    //    3、获取分辨率
    CGFloat width = size_screen.width*scale_screen;
    CGFloat height = size_screen.height*scale_screen;
    CGSize phoneSize = CGSizeMake(width, height);
    return phoneSize;
}

//获取运营商
+ (NSString *)getCurrentOperator {
    //    创建对象
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    //    获取运行商的名称
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mCarrier = [NSString stringWithFormat:@"%@",[carrier carrierName]];
    return mCarrier;
}

+ (NSString *)getCurrentNerWork {
    NSString *mConnectType = @"";
    
    BGReachability *reach = [BGReachability reachabilityWithHostName:@"www.apple.com"];
    switch([reach currentReachabilityStatus])
    {
        case NotReachable:
            //其他处理
            mConnectType = @"当前网络状态不可达";
            break;
            
        case ReachableViaWiFi:
            //其他处理
            mConnectType = @"Wifi";
            break;
            
        case ReachableVia2G:
            mConnectType = @"2G";
            //其他处理
            break;
            
        case ReachableVia3G:
            mConnectType = @"3G";
            //其他处理
            break;
            
        case ReachableVia4G:
            mConnectType = @"4G";
            //其他处理
            break;
            
        case ReachableVia5G:
            mConnectType = @"5G";
            //其他处理
            break;
            
        case ReachableViaWWAN:
            mConnectType = @"WWAN";
            //其他处理
            break;
            
        default:
            mConnectType = @"未知";
            //其他处理
            break;
    }
    NSLog(@"当前网络状态 mConnectType = %@",mConnectType);
    return mConnectType;
}

+ (NSString *)getUser_agnet {
    NSString *userAgent = [[NSUserDefaults standardUserDefaults]valueForKey:@"yk_navigator_userAgent"];
    if (!userAgent) {
        webView = [[WKWebView alloc]initWithFrame:CGRectZero];
        [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if(result){
                [[NSUserDefaults standardUserDefaults]setValue:result forKey:@"yk_navigator_userAgent"];
                webView = nil;
            }
        }];
    } else {
        return userAgent;
    }
    return @"";
}

//获取设备当前网络IP地址（包括4G 等）
+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

//获取所有相关IP信息
+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
