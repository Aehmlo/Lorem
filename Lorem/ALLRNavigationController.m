//
//  ALLRNavigationController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRNavigationController.h"

@interface ALLRNavigationController ()

@end

@implementation ALLRNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if(self = [super initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]]){
        self.navigationBar.opaque = YES;
        self.navigationBar.barTintColor = [UIColor DOBlueColor];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.translucent = NO;
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.viewControllers = @[rootViewController];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [self.visibleViewController respondsToSelector:@selector(preferredStatusBarStyle)] ? [self.visibleViewController preferredStatusBarStyle] : UIStatusBarStyleLightContent;
}

@end
