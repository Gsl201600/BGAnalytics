//
//  BGConstants.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGConstants.h"

NSString * const kSDKVersion = @"0.0.1";

@implementation BGConstants

+ (NSString *)toString:(BGAnalyticsType)type {
    NSString *typeStr = @"";
    switch (type) {
        case BGAnalyticsTypeLogin:
            typeStr = @"r_login";
            break;
        case BGAnalyticsTypePay:
            typeStr = @"r_pay";
            break;
        case BGAnalyticsTypeProtocol:
            typeStr = @"r_protocol";
            break;
        case BGAnalyticsTypeRuntime:
            typeStr = @"r_runtime_log";
            break;
        case BGAnalyticsTypeWarning:
            typeStr = @"r_warning_log";
            break;
        case BGAnalyticsTypeError:
            typeStr = @"r_error_log";
            break;
        case BGAnalyticsTypeCrash:
            typeStr = @"r_crash";
            break;
            
        default:
            break;
    }
    return typeStr;
}

+ (NSNumber *)toNumber:(BGAnalyticsType)type {
    return [NSNumber numberWithInteger:type];
}

@end
