//
//  ViewController.m
//  BGAnalyticsDemo
//
//  Created by BG on 2023/8/30.
//

#import "ViewController.h"
#import <BGAnalyticsKit/BGAnalyticsKit.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
    [self reloadData];
}

- (void)configUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
}

- (void)reloadData {
    self.dataSource = @[@"设置用户信息",
                        @"BGAnalyticsTypeLogin",
                        @"BGAnalyticsTypePay",
                        @"BGAnalyticsTypeProtocol",
                        @"BGAnalyticsTypeRuntime",
                        @"BGAnalyticsTypeWarning",
                        @"BGAnalyticsTypeError",
                        @"BGAnalyticsTypeCrash"];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self setUserInfo];
            break;
        case 1:
            [BGAnalytics track:BGAnalyticsTypeLogin];
            break;
        case 2:
            [BGAnalytics track:BGAnalyticsTypePay name:@"Pay..."];
            break;
        case 3:
            [BGAnalytics track:BGAnalyticsTypeProtocol name:@"Protocol3" parameters:@{@"test":@"testValue"}];
            break;
        case 4:
            [BGAnalytics track:BGAnalyticsTypeRuntime];
            break;
        case 5:
            [BGAnalytics track:BGAnalyticsTypeWarning];
            break;
        case 6:
            [BGAnalytics track:BGAnalyticsTypeError];
            break;
        case 7:
            [BGAnalytics track:BGAnalyticsTypeCrash];
            break;
            
        default:
            break;
    }
}

- (void)setUserInfo {
    BGUserInfo *userInfo = [[BGUserInfo alloc] init];
    userInfo.uid = @"1";
    userInfo.plat_id = @"11";
    userInfo.role_id = @"wang";
    [BGAnalytics setUserInfo:userInfo];
}

@end
