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

#if 0
Yes, I did really just forward-declare my own class.
Because apparently #importing the header isn't enough for Xcode.
Why must Xcode suck so much?
#endif

@interface ALLRDropletMoreViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    UIToolbar *toolbar;
    UIPickerView *pv;
}

- (instancetype)initWithParent:(id)parent; //Can't use ALLRDropletDetailViewController because Xcode doesn't recognize it as a type.

@property (nonatomic, retain) ALLRDroplet *droplet;
@property (nonatomic, retain) id parent; //See line 26.
@property (nonatomic, retain) UITableViewController *tableViewController;

@end
