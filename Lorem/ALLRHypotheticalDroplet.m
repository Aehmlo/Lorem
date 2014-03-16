//
//  ALLRHypotheticalDroplet.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 3/15/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRHypotheticalDroplet.h"

@interface ALLRDroplet ()

- (instancetype)_init;

@end

@implementation ALLRHypotheticalDroplet

+ (instancetype)newDropletWithID:(NSUInteger)id{
    ALLRHypotheticalDroplet *droplet = (ALLRHypotheticalDroplet *)[[self alloc] _init];
    droplet.id = id;
    return droplet;
}

@end
