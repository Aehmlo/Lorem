//
//  ALLRRootViewController.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALLRDropletManager.h"
#import "ALLRDropletDetailViewController.h"
#import "ALLRLoginViewController.h"

#import "UIColor+DOColors.h"

@interface ALLRRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableViewController *tableViewController;

@end
