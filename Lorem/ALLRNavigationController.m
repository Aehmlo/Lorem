//
//  ALLRNavigationController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRNavigationController.h"
#import "ALLRLoginViewController.h"

@interface ALLRNavigationController ()

@end

@implementation ALLRNavigationController

- (void)requireLogin{
    ALLRLoginViewController *loginViewController = [[ALLRLoginViewController alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:loginViewController animated:NO];
    });
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if(self = [super initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[UIToolbar class]]){
        self.navigationBar.opaque = YES;
        self.navigationBar.barTintColor = [UIColor DOBlueColor];
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.translucent = NO;
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        self.viewControllers = @[rootViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requireLogin) name:@"com.aehmlo.lorem/loginRequired" object:nil];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [self.visibleViewController respondsToSelector:@selector(preferredStatusBarStyle)] ? [self.visibleViewController preferredStatusBarStyle] : UIStatusBarStyleLightContent;
}

@end
