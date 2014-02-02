//
//  ALLRDropletMoreViewController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRDropletMoreViewController.h"

@interface ALLRDropletMoreViewController ()

@end

@implementation ALLRDropletMoreViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (void)dropletManagerDidUpdate{
    if ([[ALLRDropletManager sharedManager] dropletWithID:self.droplet.id]){
        self.droplet = [[ALLRDropletManager sharedManager] dropletWithID:self.droplet.id];
        [self.tableViewController.tableView reloadData];
    } else [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.droplet.locked) return;
    switch(indexPath.row){
        case 0:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Snapshot Name" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Snapshot", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"%@-%0.0f", self.droplet.name, [[NSDate date] timeIntervalSince1970]];
            alert.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView){
                return ([[alertView textFieldAtIndex:0].text length]>0);
            };
            alert.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex){
                 if(buttonIndex == alertView.firstOtherButtonIndex){
                     self.parent.droplet.status = @"Snapshot in progress";
                     [self.parent.tableViewController.tableView reloadData];
                     [[ALLRDropletManager sharedManager] takeSnapshotOfDroplet:self.droplet withName:[alertView textFieldAtIndex:0].text?:@"" completion:^(BOOL completed){
                         [[ALLRDropletManager sharedManager] reloadDropletsWithCompletion:^(BOOL completion){
                             [self.parent.tableViewController.tableView reloadData];
                         }];
                     }];
                 }
            };
            [alert show];
            break;
        }case 1:{
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Resetting your root password will reboot your droplet, and a new root password will be emailed to you. This cannot be undone."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Reset Root Password"
                                                   otherButtonTitles:nil];
            
            as.actionSheetStyle = UIActionSheetStyleAutomatic;
            as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                if(buttonIndex==0){
                        [[ALLRDropletManager sharedManager] resetRootPasswordForDroplet:self.droplet completion:^(BOOL success){
                            if(success) NSLog(@"Successfully shut down droplet.");
                            else NSLog(@"Error occured while shutting down droplet.");
                            [self.droplet reloadStateWithCompletion:^(BOOL success){
                                [[[UIAlertView alloc] initWithTitle:success?@"Password Reset Successful":@"Password Reset Failed" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                            }];
                        }];
                }
            };
            [as showInView:self.view];
            break;
        }case 2:{
            UIActionSheet *_as = [[UIActionSheet alloc] initWithTitle:@"Destroying a droplet cannot be undone. Please make sure you've backed up everything you need before continuing."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Destroy Droplet"
                                                   otherButtonTitles:nil];
            
            _as.actionSheetStyle = UIActionSheetStyleAutomatic;
            _as.tapBlock = ^(UIActionSheet *sheet, NSInteger index){
                if(index) return;
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Are you absolutely sure you want to destroy your droplet?"
                                                                delegate:nil
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:@"Destroy Droplet"
                                                       otherButtonTitles:nil];
                
                as.actionSheetStyle = UIActionSheetStyleAutomatic;
                as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                    if(buttonIndex==0){
                        [[ALLRDropletManager sharedManager] destroyDroplet:self.droplet completion:^(BOOL success){
                            [[ALLRDropletManager sharedManager] reloadDropletsWithCompletion:^(BOOL success){
                                [self.navigationController popToRootViewControllerAnimated:YES];
                            }];
                        }];
                    }
                };
                [as showInView:self.view];
            };
            [_as showInView:self.view];
            break;
        }
        default:
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALLRDropletDetailTableViewCell"];
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ALLRDropletDetailTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Take Snapshot";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @"Reset Root Password";
            cell.textLabel.textColor = [UIColor DORedColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            cell.textLabel.text = @"Destroy Droplet";
            cell.textLabel.textColor = [UIColor DORedColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        default:
            break;
    }
    return cell;
}

- (instancetype)initWithParent:(ALLRDropletDetailViewController *)parent{
    if ((self = [super init])){
        self.parent = parent;
        self.droplet = parent.droplet;
        self.title = @"More Options";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropletManagerDidUpdate) name:@"com.aehmlo.lorem/dropletManagerDidUpdate" object:nil];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableViewController.tableView.frame = self.view.bounds;
    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.delegate = self;
    self.tableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableViewController.tableView];
    [self.tableViewController.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
