//
//  BGEventInfo.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGEventInfo.h"
#import "BGSessionRequest.h"
#import "BGAnalyticsKit.h"
#import "BGUserInfo.h"
#import "BGConfigOptions.h"
#import "BGValidator.h"
#import "BGDeviceInfor.h"
#import "BGConstants+Private.h"

@implementation BGEventInfo

+ (NSDictionary *)reportBaseParameters {
    NSString *appId = [BGValidator toValidString:BGAnalytics.configOptions.app_id];
    NSString *channelId = [BGValidator toValidString:BGAnalytics.configOptions.channel_id];
    
    NSDictionary *baseParams = @{@"record_uid":[BGSessionRequest sessionID],
                             @"app_id":appId,
                             @"channel_id":channelId,
                             @"device_name":[BGDeviceInfor getDeviceName],
                             @"device_model":[BGDeviceInfor getDeviceModel],
                             @"os_version":[BGDeviceInfor getOs_version],
                             @"device_code":[BGDeviceInfor deviceCode],
                             @"memory_size":[BGDeviceInfor totalMemorySize],
                             @"device_size":NSStringFromCGSize([BGDeviceInfor getPhoneSize]),
                             @"IDFV":[BGDeviceInfor getIDFV],
                             @"app_version":[BGDeviceInfor appVersion],
                             @"app_bundle_id":[BGDeviceInfor appBundleId],
                             @"app_build_version":[BGDeviceInfor appBuildVersion],
                             @"app_name":[BGDeviceInfor appName],
                             @"sdk_version":kSDKVersion};
    return baseParams;
}

+ (NSDictionary *)reportParametersByType:(NSNumber *)type name:(NSString *)name parameters:(NSDictionary<NSString *, id> *)parameters {
    NSString *uId = [BGValidator toValidString:BGAnalytics.userInfo.uid];
    NSString *platId = [BGValidator toValidString:BGAnalytics.userInfo.plat_id];
    NSString *roleId = [BGValidator toValidString:BGAnalytics.userInfo.role_id];
    
    name = [BGValidator toValidString:name];
    if (![BGValidator isValidDictionary:parameters]) {
        parameters = @{};
    }
    
    NSDictionary *eventParams = @{@"event_type":type,
                                  @"uid":uId,
                                  @"plat_id":platId,
                                  @"role_id":roleId,
                                  @"operator":[BGDeviceInfor getCurrentOperator],
                                  @"network_state":[BGDeviceInfor getCurrentNerWork],
                                  @"client_time":[BGDeviceInfor clientTime],
                                  @"event_name":name,
                                  @"data":parameters};
    return eventParams;
}

@end
