//
//  UIColor+DOColors.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "UIColor+DOColors.h"

@implementation UIColor (DOColors)

+ (instancetype)DOBlueColor{
    return [self colorWithRed:57.0f/255.0f green:139.0f/255.0f blue:206.0f/255.0f alpha:1];
}
+ (instancetype)DORedColor{
    return [self colorWithRed:204.0f/255.0f green:81.0f/255.0f blue:82.0f/255.0f alpha:1];
}
+ (instancetype)DOGreenColor{
    return [self colorWithRed:62.0f/255.0f green:192.0f/255.0f blue:66.0f/255.0f alpha:1];
}

@end
