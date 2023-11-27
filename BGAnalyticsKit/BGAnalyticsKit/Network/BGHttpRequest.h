//
//  BGHttpRequest.h
//  TestDemo
//
//  Created by BG on 2022/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGHttpRequest : NSMutableURLRequest

+ (instancetype)GETRequestWithURL:(NSString *)URL body:(id)body;
+ (instancetype)POSTRequestWithURL:(NSString *)URL body:(id)body;

@end

NS_ASSUME_NONNULL_END
