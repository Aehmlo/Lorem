//
//  ALLRLoginViewController.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 2/1/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALLRCredentialManager.h"
#import "UIColor+DOColors.h"

@interface ALLRLoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UITableViewController *tableViewController;
@property (nonatomic, retain) UITextField *clientIDEntryField;
@property (nonatomic, retain) UITextField *APIKeyEntryField;

@end
