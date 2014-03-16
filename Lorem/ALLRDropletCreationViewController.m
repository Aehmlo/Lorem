//
//  ALLRDropletCreationViewController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 3/15/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRDropletCreationViewController.h"

@interface ALLRDropletCreationViewController ()

@end

@implementation ALLRDropletCreationViewController

- (instancetype)initWithDroplet:(ALLRHypotheticalDroplet *)droplet{
    if((self = [super init])){
        self.title = [@"Creating " stringByAppendingString:droplet.name];
        self.droplet = droplet;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

@end
