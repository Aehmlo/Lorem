//
//  ALLRRootViewController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRRootViewController.h"

@interface ALLRRootViewController ()

@end

@implementation ALLRRootViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[ALLRDropletManager sharedManager].droplets count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoremDropletCell"];
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoremDropletCell"];
    cell.textLabel.text = [(ALLRDroplet *)[ALLRDropletManager sharedManager].droplets[indexPath.row] name];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

- (instancetype)init{
    if((self = [super init])){
        self.title = @"Droplets";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"com.aehmlo.lorem/dropletManagerDidUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:@"com.aehmlo.lorem/reloadDroplets" object:nil];
    }
    return self;
}

- (void)refresh{
    [self.tableViewController.refreshControl beginRefreshing];
    [self.tableViewController.tableView reloadData];
    [self.tableViewController.refreshControl endRefreshing];
}

- (void)reloadTableData{
    [self.tableViewController.refreshControl beginRefreshing];
    [[ALLRDropletManager sharedManager] reloadDropletsWithCompletion:^(BOOL success){
        if(success){
            [ALLRMiscellaneousAPIInfoManager sharedManager];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewController.tableView reloadData];
                [self.tableViewController.refreshControl endRefreshing];
            });
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ALLRDropletDetailViewController *dropletViewController = [[ALLRDropletDetailViewController alloc] initWithDroplet:[ALLRDropletManager sharedManager].droplets[indexPath.row]];
    [self.navigationController pushViewController:dropletViewController animated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableViewController.tableView.frame = self.view.bounds;
    self.tableViewController.tableView.delegate = self;
    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableViewController.refreshControl = [[UIRefreshControl alloc] init];
    self.tableViewController.refreshControl.tintColor = [UIColor DOBlueColor];
    [self.tableViewController.refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.tableViewController.tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        ALLRLoginViewController *loginViewController = [[ALLRLoginViewController alloc] init];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }else{
        [[ALLRDropletManager sharedManager] reloadDropletsWithCompletion:^(BOOL success){
            if(success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableViewController.tableView reloadData];
                });
            }
        }];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
