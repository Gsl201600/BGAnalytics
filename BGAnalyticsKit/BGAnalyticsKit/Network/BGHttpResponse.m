//
//  BGHttpResponse.m
//  TestDemo
//
//  Created by BG on 2022/8/23.
//

#import "BGHttpResponse.h"

@implementation BGHttpResponse

- (NSString *)bodyString{
    if (!self.bodyData) {
        return nil;
    }
    return [[NSString alloc] initWithData:self.bodyData encoding:NSUTF8StringEncoding];
}

- (id)bodyObject{
    if (!self.bodyData) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:self.bodyData options:NSJSONReadingMutableContainers error:nil];
}

- (BOOL)isValid{
    return (self.bodyData && (self.statusCode == 200) && !self.error);
}

@end
