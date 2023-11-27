//
//  BGConvertor.m
//  BGCoreKit
//
//  Created by BG on 2023/6/19.
//

#import "BGConvertor.h"

@implementation BGConvertor

+ (NSString *)dataToString:(NSData *)data {
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id)dataToJSONObject:(NSData *)data {
    if (!data) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

+ (NSString *)JSONObjectToString:(id)object {
    if (!object || ![NSJSONSerialization isValidJSONObject:object]) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    if (!data) {
        return nil;
    }
    return [self dataToString:data];
}

+ (id)stringToJSONObject:(NSString *)string {
    if (!string) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

@end
