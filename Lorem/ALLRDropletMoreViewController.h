//
//  ALLRDropletMoreViewController.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALLRDropletManager.h"
#import "ALLRMiscellaneousAPIInfoManager.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "UIColor+DOColors.h"

#import "ALLRDropletDetailViewController.h"

@interface ALLRDropletMoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithParent:(ALLRDropletDetailViewController *)parent;

@property (nonatomic, retain) ALLRDroplet *droplet;
@property (nonatomic, retain) ALLRDropletDetailViewController *parent;
@property (nonatomic, retain) UITableViewController *tableViewController;

@end
