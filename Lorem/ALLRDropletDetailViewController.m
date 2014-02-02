//
//  ALLRDropletDetailViewController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRDropletDetailViewController.h"

@interface ALLRDropletMoreViewController : UIViewController

- (instancetype)initWithParent:(ALLRDropletDetailViewController *)parent;

@end

@implementation ALLRDropletDetailViewController

static BOOL stringIsValidName(NSString *string){
    NSCharacterSet *_s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-+"];
    NSCharacterSet *s = [_s invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:s];
    return (r.location == NSNotFound);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
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
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rename Droplet" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == alertView.firstOtherButtonIndex) {
                    self.droplet.status = @"Renaming";
                    [self.tableViewController.tableView reloadData];
                    [[ALLRDropletManager sharedManager] renameDroplet:self.droplet to:[[alertView textFieldAtIndex:0] text] completion:^(BOOL success){
                        if(success){
                            self.droplet.name = [[alertView textFieldAtIndex:0] text];
                            self.title = [[alertView textFieldAtIndex:0] text];
                            [self.tableViewController.refreshControl beginRefreshing];
                            [self.tableViewController.tableView reloadData];
                            [self.tableViewController.refreshControl endRefreshing];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/reloadDroplets" object:nil];
                        }
                    }];
                }
            };
            
            alert.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView){
                return ([[[alertView textFieldAtIndex:0] text] length] > 0 && stringIsValidName([[alertView textFieldAtIndex:0] text]));
            };
            [alert show];
            break;
        }
        case 1:{
            if([self.droplet.status isEqualToString:@"active"]){
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Power Actions"
                                                                delegate:nil
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Shut Down", @"Reboot", nil];
                
                as.actionSheetStyle = UIActionSheetStyleAutomatic;
                as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                    switch(buttonIndex){
                        case 0:{
                            self.droplet.status = @"Shutting Down";
                            [self.tableViewController.tableView reloadData];
                            [[ALLRDropletManager sharedManager] shutDownDroplet:self.droplet completion:^(BOOL success){
                                if(success) NSLog(@"Successfully shut down droplet.");
                                else NSLog(@"Error occured while shutting down droplet.");
                                [self.droplet reloadStateWithCompletion:^(BOOL success){
                                    [self.tableViewController.tableView reloadData];
                                }];
                            }];
                            break;
                        }case 1:{
                            self.droplet.status = @"Rebooting";
                            [self.tableViewController.tableView reloadData];
                            [[ALLRDropletManager sharedManager] rebootDroplet:self.droplet completion:^(BOOL success){
                                if(success) NSLog(@"Successfully rebooted droplet.");
                                else NSLog(@"Error occured while rebooting droplet.");
                                [self.droplet reloadStateWithCompletion:^(BOOL success){
                                    [self.tableViewController.tableView reloadData];
                                }];
                            }];
                            break;
                        }default:
                            break;
                    }
                };
                [as showInView:self.view];
            }else if([self.droplet.status isEqualToString:@"off"]){
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Power Actions"
                                                                delegate:nil
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Boot", nil];
                
                as.actionSheetStyle = UIActionSheetStyleAutomatic;
                as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                    if(buttonIndex==0){
                        self.droplet.status = @"Booting";
                        [self.tableViewController.tableView reloadData];
                        [[ALLRDropletManager sharedManager] bootDroplet:self.droplet completion:^(BOOL success){
                            [self.droplet reloadStateWithCompletion:^(BOOL success){
                                [self.tableViewController.tableView reloadData];
                            }];
                        }];
                    }
                };
                [as showInView:self.view];
            }
            break;
        }case 2:{
            pv = [[UIPickerView alloc] initWithFrame:(CGRect){{0, self.view.bounds.size.height+44},{self.view.bounds.size.width, 200}}];
            pv.delegate = self;
            pv.dataSource = self;
            pv.showsSelectionIndicator = YES;
            [pv reloadAllComponents];
            [pv selectRow:[[ALLRMiscellaneousAPIInfoManager sharedManager] indexForSizeID:self.droplet.sizeID] inComponent:0 animated:NO];
            [self.view addSubview:pv];
            toolbar = [[UIToolbar alloc] initWithFrame:(CGRect){{0, self.view.bounds.size.height},{self.view.bounds.size.width, 44}}];
            UIBarButtonItem *middleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped)];
            cancelButton.tintColor = [UIColor DOBlueColor];
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped)];
            doneButton.tintColor = [UIColor DOBlueColor];
            [toolbar setItems:@[cancelButton, middleSpace, doneButton]];
            [self.view addSubview:toolbar];
            self.tableViewController.tableView.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25f animations:^{
                pv.frame = (CGRect){{0, pv.frame.origin.y-244},{pv.frame.size.width, pv.frame.size.height}};
                toolbar.frame = (CGRect){{0, toolbar.frame.origin.y-244},{toolbar.frame.size.width, toolbar.frame.size.height}};
            }];
            break;
        }case 6:{
            ALLRDropletMoreViewController *viewController = [[ALLRDropletMoreViewController alloc] initWithParent:self];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALLRDropletDetailTableViewCell"];
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ALLRDropletDetailTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.droplet.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @"Status";
            cell.detailTextLabel.text = [self.droplet.status capitalizedString];
            if([self.droplet.status isEqualToString:@"active"]) cell.detailTextLabel.textColor = [UIColor DOGreenColor];
            else if([self.droplet.status isEqualToString:@"off"]) cell.detailTextLabel.textColor = [UIColor DORedColor];
            else cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = [[ALLRMiscellaneousAPIInfoManager sharedManager] sizeStringForSizeID:self.droplet.sizeID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 3:
            cell.textLabel.text = @"Public IP Address";
            cell.detailTextLabel.text = self.droplet.IP;
            break;
        case 4:
            cell.textLabel.text = @"Private IP Address";
            cell.detailTextLabel.text = [self.droplet.privateIP isEqualToString:@""] ? @"n/a" : self.droplet.privateIP;
            break;
        case 5:
            cell.textLabel.text = @"Backups Enabled";
            cell.detailTextLabel.text = self.droplet.backupsActive ? @"Yes" : @"No";
            break;
        case 6:
            cell.textLabel.text = @"More";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return cell;
}

- (instancetype)initWithDroplet:(ALLRDroplet *)droplet{
    if ((self = [super init])){
        self.droplet = droplet;
        self.title = droplet.name;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)cancelButtonTapped{
    [UIView animateWithDuration:0.25f animations:^{
        pv.frame = (CGRect){{0, pv.frame.origin.y+244},{pv.bounds.size.width, pv.bounds.size.height}};
        toolbar.frame = (CGRect){{0, toolbar.frame.origin.y+244},{pv.bounds.size.width, toolbar.bounds.size.height}};
    }completion:^(BOOL finished){
        if(finished){
            [pv removeFromSuperview];
            [toolbar removeFromSuperview];
            self.tableViewController.tableView.userInteractionEnabled = YES;
            pv = nil;
        }
    }];
}

- (void)doneButtonTapped{
    [UIView animateWithDuration:0.25f animations:^{
        pv.frame = (CGRect){{0, pv.frame.origin.y+244},{pv.bounds.size.width, pv.bounds.size.height}};
        toolbar.frame = (CGRect){{0, toolbar.frame.origin.y+244},{pv.bounds.size.width, toolbar.bounds.size.height}};
    }completion:^(BOOL finished){
        if(finished){
            [pv removeFromSuperview];
            [toolbar removeFromSuperview];
            self.tableViewController.tableView.userInteractionEnabled = YES;
            NSUInteger index = [pv selectedRowInComponent:0];
            NSUInteger id = [[ALLRMiscellaneousAPIInfoManager sharedManager].sizes[index][@"id"] unsignedIntegerValue];
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Resizing your droplet will shut down your droplet and perform a \"fast resize\", and will affect the number of processors and memory allocated to the droplet. This may take up to one minute."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Resize",nil];
            
            as.actionSheetStyle = UIActionSheetStyleAutomatic;
            as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                if(buttonIndex==0){
                    self.droplet.status = @"Resizing";
                    [self.tableViewController.tableView reloadData];
                    [[ALLRDropletManager sharedManager] resizeDroplet:self.droplet toSize:id completion:^(BOOL completion){
                        self.droplet.status = @"off";
                        [self.tableViewController.tableView reloadData];
                    }];
                }
            };
            [as showInView:self.view];
            pv = nil;
        }
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[[ALLRMiscellaneousAPIInfoManager sharedManager].sizes[row][@"name"] stringByReplacingOccurrencesOfString:@"MB" withString:@" MB"] stringByReplacingOccurrencesOfString:@"GB" withString:@" GB"]; //This isn't at all unstable. Nope. No way. Impossible.
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[ALLRMiscellaneousAPIInfoManager sharedManager].sizes count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.view.bounds.size.width;
}

@end
