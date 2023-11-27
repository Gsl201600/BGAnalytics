//
//  BGUserInfo.h
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGUserInfo : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *plat_id;
@property (nonatomic, copy) NSString *role_id;

@end

NS_ASSUME_NONNULL_END
