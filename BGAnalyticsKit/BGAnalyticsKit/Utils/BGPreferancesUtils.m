//
//  BGPreferancesUtils.m
//  BGCoreKit
//
//  Created by BG on 2023/2/20.
//

#import "BGPreferancesUtils.h"

@implementation BGPreferancesUtils

//获取UserDefaults
+ (id)userDefaultsForKey:(NSString *)key{
    id userDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return userDefaults;
}

//设置UserDefaults
+ (void)setUserDefaults:(id)object forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//获取UserDefaults Bool
+ (BOOL)userDefaultsBoolForKey:(NSString *)key{
    BOOL userDefaults = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    return userDefaults;
}

//设置UserDefaults Bool
+ (void)setUserDefaultsBool:(BOOL)isBool forKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setBool:isBool forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 清空某个key的值
+ (void)cleanUserDefaultsForKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)cleanAllUserDefaults{
    NSString *appDomainStr = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomainStr];
}

@end
