# BGAnalytics

## 工程项目结构说明
1. AppInfo    -> 统计设备信息
2. Config     -> 初始化配置
3. Core       -> 工程管理类和入口
4. Exception  -> 异常崩溃处理
5. Network    -> 网络基础库
6. Router     -> 路由地址
7. Server     -> 请求服务
8. Tracker    -> 统计追踪
9. Utils      -> 工具类


## SDK 接入文档
1. 导入`BGAnalyticsKit.framework`
2. 在`application:didFinishLaunchingWithOptions:`中调用
```
BGConfigOptions *config = [[BGConfigOptions alloc] init];
config.app_id = @"12";
config.channel_id = @"1";
[BGAnalytics startWithConfigOptions:config];
```
BGConfigOptions参数说明

|参数|是否必传|说明|
|:---:|:---:|:---:|
|app_id|是|应用的appid|
|channel_id|是|应用的渠道id|
|domain|否|上报日志的域名，默认为http://10.235.99.80:12346|
|isRealtime|否|是否实时上报, 默认NO|
|periodicTimerMinute|否|定时上报时间单位分, 默认5分钟|
|flushItem|否|上报条数, 默认10条|
|disableLog|否|关闭 log 日志, 默认NO|
|disableSDK|否|禁用 SDK。设置后，SDK 将不采集事件，不发送网络请求，默认为NO|

3. 在合适位置调用`setUserInfo:`，如登录成功时，调用该接口后，上报日志中将包含用户信息维度
```
BGUserInfo *userInfo = [[BGUserInfo alloc] init];
userInfo.uid = @"1";
userInfo.plat_id = @"11";
userInfo.role_id = @"wang";
[BGAnalytics setUserInfo:userInfo];
```

4. 追踪上报接口
```
+ (void)track:(BGAnalyticsType)type;
+ (void)track:(BGAnalyticsType)type name:(nullable NSString *)name;
+ (void)track:(BGAnalyticsType)type name:(nullable NSString *)name parameters:(nullable NSDictionary<NSString *, id> *)parameters;
```
以上三个接口，功能相同，后面两个接口，只是上报的信息更加详细，允许调用方自定义事件名和参数
```
[BGAnalytics track:BGAnalyticsTypeProtocol name:@"Protocol3" parameters:@{@"test":@"testValue"}];
```

该`SDK`分七大上报类型：
* `BGAnalyticsTypeLogin | BGAnalyticsTypePay | BGAnalyticsTypeError | BGAnalyticsTypeCrash`
登录、支付、错误和崩溃为实时上报类型，只要调用该类型事件，将立即上报服务器

* `BGAnalyticsTypeProtocol | BGAnalyticsTypeRuntime | BGAnalyticsTypeWarning`
这些事件不会立即上报服务器，会在相同事件达到设置的上报条数（`默认10条`）后，进行上报，或者在达到设置的定时上报时间（`默认5分钟`）后，进行上报

`SDK`除了上面的上报策略，还会在每次启动时，自动检测是否存在未上报的事件，如有，将自动上报
`SDK`内置的`Crash`事件，会在应用闪退后，自动记录闪退日志，在下次启动时自动上报

5. 强制把数据传到对应的服务器上
调用`flush`接口，则不论限制条件是否满足，都尝试向服务器上传一次数据
`[BGAnalytics flush];`

6. 删除本地缓存的全部事件
`[BGAnalytics deleteAll];`
一旦调用该接口，将会删除本地缓存的全部事件，请慎用！
