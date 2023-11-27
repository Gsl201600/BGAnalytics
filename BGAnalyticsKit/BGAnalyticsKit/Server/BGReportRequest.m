//
//  BGReportRequest.m
//  BGAnalytics
//
//  Created by BG on 2023/8/31.
//

#import "BGReportRequest.h"
#import "BGHttpClient.h"
#import "BGRouter.h"
#import "BGLogger.h"

@implementation BGReportRequest

+ (void)reportEventData:(NSDictionary *)data completion:(nullable dispatch_block_t)completion {
    if ([BGHttpClient checkNetwork]) {
        NSString *sessionUrl = [BGRouter sharedInstance].recordUrl;
        BGHttpClient *client = [BGHttpClient client];
        BGHttpResponse *res = [client syncPOSTRequest:sessionUrl body:data];
        NSDictionary *resDict = res.bodyObject;
        if (res.isValid && [resDict[@"status"] integerValue] == 0) {
            if (completion) {
                completion();
            }
        }
        BGLogInfo(@"URL:%@\n body:%@\n res:%@\n", sessionUrl, data, resDict);
    }
}

@end
