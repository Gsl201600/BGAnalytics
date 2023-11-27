//
//  BGRouter.m
//  BGAnalytics
//
//  Created by BG on 2023/8/30.
//

#import "BGRouter.h"
#import "BGValidator.h"

static NSString * const kBaseUrl = @"http://10.235.99.80:12346";
static NSString * const kSessionPath = @"/v1/sdk/client/request/session";
static NSString * const kRecordPath = @"/v1/sdk/client/report/record";

@implementation BGRouter

static BGRouter *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BGRouter alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseUrl = kBaseUrl;
    }
    return self;
}

- (void)setBaseUrl:(NSString *)baseUrl {
    if ([BGValidator isValidString:baseUrl] && [baseUrl hasPrefix:@"http"]) {
        _baseUrl = baseUrl;
    }
}

- (NSString *)sessionUrl {
    return [self.baseUrl stringByAppendingPathComponent:kSessionPath];
}

- (NSString *)recordUrl {
    return [self.baseUrl stringByAppendingPathComponent:kRecordPath];
}

@end
