//
//  ALLRDropletCreationViewController.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 3/15/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALLRHypotheticalDroplet.h"

@interface ALLRDropletCreationViewController : UIViewController

- (instancetype)initWithDroplet:(ALLRHypotheticalDroplet *)droplet;

@property (nonatomic, retain) ALLRHypotheticalDroplet *droplet;

@end
