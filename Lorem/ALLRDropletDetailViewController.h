//
//  ALLRDropletDetailViewController.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ALLRDropletManager.h"
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "UIColor+DOColors.h"

@interface ALLRDropletDetailViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    UIPickerView *pv;
    UIToolbar *toolbar;
}

- (instancetype)initWithDroplet:(ALLRDroplet *)droplet;

@property (nonatomic, retain) ALLRDroplet *droplet;
@property (nonatomic, retain) UITableViewController *tableViewController;

@end
