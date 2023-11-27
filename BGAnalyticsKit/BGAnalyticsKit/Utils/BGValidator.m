//
//  BGValidator.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGValidator.h"

@implementation BGValidator

+ (BOOL)isValidString:(NSString *)string {
    return ([string isKindOfClass:[NSString class]] && ([string length] > 0));
}

+ (NSString *)toValidString:(NSString *)string {
    if ([self isValidString:string]) {
        return string;
    }else{
        return @"";
    }
}

+ (BOOL)isValidArray:(NSArray *)array {
    return ([array isKindOfClass:[NSArray class]] && ([array count] > 0));
}

+ (BOOL)isValidDictionary:(NSDictionary *)dictionary {
    return ([dictionary isKindOfClass:[NSDictionary class]] && ([dictionary count] > 0));
}

+ (BOOL)isValidData:(NSData *)data {
    return ([data isKindOfClass:[NSData class]] && ([data length] > 0));
}

@end
