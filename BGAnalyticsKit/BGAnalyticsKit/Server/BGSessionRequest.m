//
//  BGSessionRequest.m
//  BGAnalytics
//
//  Created by BG on 2023/8/30.
//

#import "BGSessionRequest.h"
#import "BGHttpClient.h"
#import "BGRouter.h"
#import "BGLogger.h"
#import "BGPreferancesUtils.h"
#import "BGValidator.h"

static NSString * const kSessionID = @"gs_session_request_sessionID";

@implementation BGSessionRequest

+ (NSString *)sessionID {
    NSString *sessionID = [BGPreferancesUtils userDefaultsForKey:kSessionID];
    if ([BGValidator isValidString:sessionID]) {
        return sessionID;
    }
    [self getSessionIDWithCompletion:nil];
    return @"";
}

+ (void)getSessionIDWithCompletion:(nullable dispatch_block_t)completion {
    NSString *sessionUrl = [BGRouter sharedInstance].sessionUrl;
    BGHttpClient *client = [BGHttpClient client];
    [client asyncGETRequest:sessionUrl body:nil completion:^(BGHttpResponse * _Nonnull res) {
        BGLogInfo(@"%@\n", res.bodyObject);
        NSDictionary *resDict = res.bodyObject;
        if (res.isValid && resDict[@"data"]) {
            [BGPreferancesUtils setUserDefaults:resDict[@"data"] forKey:kSessionID];
        }
        if (completion) {
            completion();
        }
    }];
}

@end
