//
//  BGHttpClient.m
//  TestDemo
//
//  Created by BG on 2022/8/23.
//

#import "BGHttpClient.h"
#import "BGHttpRequest.h"
#import "BGReachability.h"
#include <arpa/inet.h>

@interface BGHttpClient () <NSURLSessionDelegate>

@property (nonatomic, strong) BGHttpRequest *httpReq;
@property (nonatomic, strong) BGHttpResponse *httpRes;

@end

@implementation BGHttpClient

+ (BOOL)checkNetwork {
    struct sockaddr_in zeroAddress;
    
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network \n");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (instancetype)client{
    return [self clientWithBaseURL:nil];
}

+ (instancetype)clientWithBaseURL:(nullable NSString *)baseURL{
    return [[self alloc] initWithBaseURL:baseURL];
}

- (instancetype)initWithBaseURL:(NSString *)baseURL{
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
        self.completedInMainThread = YES;
        self.collectingMetrics = NO;
    }
    return self;
}

#pragma mark - 异步请求

- (void)asyncGETRequest:(NSString *)url body:(nullable id)body completion:(BGHttpResHandle)completion{
    if (self.baseURL) {
        url = [self.baseURL stringByAppendingPathComponent:url];
    }
    self.httpReq = [BGHttpRequest GETRequestWithURL:url body:body];
    
    [self asyncRequest:completion];
}

- (void)asyncPOSTRequest:(NSString *)url body:(nullable id)body completion:(BGHttpResHandle)completion{
    if (self.baseURL) {
        url = [self.baseURL stringByAppendingPathComponent:url];
    }
    self.httpReq = [BGHttpRequest POSTRequestWithURL:url body:body];
    
    [self asyncRequest:completion];
}

- (void)asyncRequest:(BGHttpResHandle)completion{
    if (self.timeoutInterval) {
        self.httpReq.timeoutInterval = self.timeoutInterval;
    }else {
        self.httpReq.timeoutInterval = 10;
    }
    
    if (self.allHTTPHeaderFields) {
        [self.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [self.httpReq setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    self.httpRes.requestTime = startTime;
    self.httpRes.requestMethod = self.httpReq.HTTPMethod;
    self.httpRes.requestUrl = self.httpReq.URL.absoluteString;
    
    NSURLSession *session = nil;
    if (self.collectingMetrics) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    }else{
        session = [NSURLSession sharedSession];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.httpReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (self.collectingMetrics) {
            [session finishTasksAndInvalidate];
        }
        
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        NSInteger timeSpent = [@((endTime - startTime) * 1000) integerValue];
        
        self.httpRes.spendTime = timeSpent;
        self.httpRes.statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        if (error) {
            self.httpRes.error = error;
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if (data) {
                self.httpRes.bodyData = data;
            }
        }
        
        if (completion) {
            if (self.completedInMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(self.httpRes);
                });
            }else {
                completion(self.httpRes);
            }
        }
    }];
    [task resume];
}

#pragma mark - 同步请求

- (BGHttpResponse *)syncGETRequest:(NSString *)url body:(nullable id)body{
    if (self.baseURL) {
        url = [self.baseURL stringByAppendingPathComponent:url];
    }
    self.httpReq = [BGHttpRequest GETRequestWithURL:url body:body];
    
    return [self syncRequest];
}

- (BGHttpResponse *)syncPOSTRequest:(NSString *)url body:(nullable id)body{
    if (self.baseURL) {
        url = [self.baseURL stringByAppendingPathComponent:url];
    }
    self.httpReq = [BGHttpRequest POSTRequestWithURL:url body:body];
    
    return [self syncRequest];
}

- (BGHttpResponse *)syncRequest{
    if (self.timeoutInterval) {
        self.httpReq.timeoutInterval = self.timeoutInterval;
    }else {
        self.httpReq.timeoutInterval = 10;
    }
    
    if (self.allHTTPHeaderFields) {
        [self.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [self.httpReq setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    self.httpRes.requestTime = startTime;
    self.httpRes.requestMethod = self.httpReq.HTTPMethod;
    self.httpRes.requestUrl = self.httpReq.URL.absoluteString;
    
    dispatch_semaphore_t requestSemaphore = dispatch_semaphore_create(0);
    
    NSURLSession *session = nil;
    if (self.collectingMetrics) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    }else{
        session = [NSURLSession sharedSession];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:self.httpReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (self.collectingMetrics) {
            [session finishTasksAndInvalidate];
        }
        
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        NSInteger timeSpent = [@((endTime - startTime) * 1000) integerValue];
        
        self.httpRes.spendTime = timeSpent;
        self.httpRes.statusCode = ((NSHTTPURLResponse *)response).statusCode;
        
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            self.httpRes.error = error;
        }else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            if (data) {
                self.httpRes.bodyData = data;
            }
        }
        
        dispatch_semaphore_signal(requestSemaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(requestSemaphore, DISPATCH_TIME_FOREVER);
    
    return self.httpRes;
}

#pragma mark - NSURLSessionDelegate 代理方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0)){
    NSURLSessionTaskTransactionMetrics *metric = [metrics.transactionMetrics lastObject];
    NSTimeInterval tcpTim = [metric.connectEndDate timeIntervalSinceDate:metric.connectStartDate] * 1000;
    NSTimeInterval dnsTim = [metric.domainLookupEndDate timeIntervalSinceDate:metric.domainLookupStartDate] * 1000;
    NSTimeInterval clientTim = [metric.requestEndDate timeIntervalSinceDate:metric.requestStartDate] * 1000;
    NSTimeInterval sslTim = [metric.secureConnectionEndDate timeIntervalSinceDate:metric.secureConnectionStartDate] * 1000;
    NSTimeInterval totalTim = [metrics.taskInterval duration] * 1000;   // 网络请求总时间
    NSTimeInterval firstPacketTim = [metric.responseStartDate timeIntervalSinceDate:metric.requestEndDate] * 1000;
//    NSString *url_str = metric.request.URL.absoluteString;
//    NSInteger statusCode  = ((NSHTTPURLResponse *)metric.response).statusCode;
    
    self.httpRes.clientWasteTime = clientTim;
    self.httpRes.totalTime = totalTim;
    self.httpRes.dnsTime = dnsTim;
    self.httpRes.sslTime = sslTim;
    self.httpRes.tcpTime = tcpTim;
    self.httpRes.firstPacketTime = firstPacketTim;
}

// 主要就是处理HTTPS请求的
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    // 判断服务器返回的证书类型, 是否是服务器信任
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (BGHttpResponse *)httpRes{
    if (!_httpRes) {
        _httpRes = [[BGHttpResponse alloc] init];
    }
    return _httpRes;
}

@end
