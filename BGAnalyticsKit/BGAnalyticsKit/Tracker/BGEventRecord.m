//
//  BGEventRecord.m
//  BGAnalytics
//
//  Created by BG on 2023/8/29.
//

#import "BGEventRecord.h"
#import "BGConvertor.h"
#import "BGValidator.h"

@implementation BGEventRecord

- (instancetype)initWithRecordID:(nullable NSString *)recordID type:(NSString *)type content:(NSString *)content {
    if (self = [super init]) {
        _recordID = recordID;
        _type = type;
        _content = content;
        NSDictionary *eventDic = [BGConvertor stringToJSONObject:content];
        if (eventDic) {
            _event = eventDic;
        }
    }
    return self;
}

- (BOOL)isValid {
    return [BGValidator isValidDictionary:self.event];
}

@end
