//
//  BGHttpRequest.m
//  TestDemo
//
//  Created by BG on 2022/8/23.
//

#import "BGHttpRequest.h"

@implementation BGHttpRequest

+ (instancetype)requestWithURL:(NSString *)URL method:(NSString *)method{
    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>+ "].invertedSet];
    
    NSParameterAssert(URL);
    
    NSURL *reqestURL = [NSURL URLWithString:URL];
    
    NSParameterAssert(reqestURL);
    
    BGHttpRequest *request = [BGHttpRequest requestWithURL:reqestURL];
    request.HTTPMethod = method;
    
    if (![request.allHTTPHeaderFields.allKeys containsObject:@"Content-Type"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    return request;
}

+ (instancetype)GETRequestWithURL:(NSString *)URL body:(id)body{
    if (body && ![URL containsString:@"?"]) {
        URL = [URL stringByAppendingString:@"?"];
    }
    
    if (body && [body isKindOfClass:[NSString class]]) {
        NSString *str = body;
        URL = [URL stringByAppendingString:str];
    }else if (body && [body isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = body;
        NSInteger index = 0;
        for (NSString *key in dic.allKeys) {
            NSString *str = [NSString stringWithFormat:@"%@=%@", key, dic[key]];
            if (!index) {
                URL = [URL stringByAppendingString:str];
            }else {
                URL = [URL stringByAppendingFormat:@"&%@", str];
            }
            index++;
        }
    }
    
    BGHttpRequest *request = [BGHttpRequest requestWithURL:URL method:@"GET"];
    
    return request;
}

+ (instancetype)POSTRequestWithURL:(NSString *)URL body:(id)body{
    NSData *data = nil;
    
    if (body && [body isKindOfClass:[NSString class]]) {
        NSString *str = body;
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    }else if (body && [NSJSONSerialization isValidJSONObject:body]) {
        data = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    }else if (body && [body isKindOfClass:[NSData class]]) {
        data = body;
    }
    
    BGHttpRequest *request = [BGHttpRequest requestWithURL:URL method:@"POST"];
    if (data) {
        request.HTTPBody = data;
    }
    return request;
}

@end
