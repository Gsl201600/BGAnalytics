//
//  BGRouter.h
//  BGAnalytics
//
//  Created by BG on 2023/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGRouter : NSObject

@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, copy, readonly) NSString *sessionUrl;
@property (nonatomic, copy, readonly) NSString *recordUrl;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
