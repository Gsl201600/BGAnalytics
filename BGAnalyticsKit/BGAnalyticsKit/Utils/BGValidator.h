//
//  BGValidator.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGValidator : NSObject

+ (BOOL)isValidString:(NSString *)string;
+ (NSString *)toValidString:(NSString *)string;

+ (BOOL)isValidDictionary:(NSDictionary *)dictionary;

+ (BOOL)isValidArray:(NSArray *)array;

+ (BOOL)isValidData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
