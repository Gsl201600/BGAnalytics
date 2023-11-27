//
//  AppDelegate.m
//  BGAnalyticsDemo
//
//  Created by BG on 2023/8/30.
//

#import "AppDelegate.h"
#import <BGAnalyticsKit/BGAnalyticsKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    BGConfigOptions *config = [[BGConfigOptions alloc] init];
    config.app_id = @"12";
    config.channel_id = @"1";
    [BGAnalytics startWithConfigOptions:config];
    return YES;
}

@end
