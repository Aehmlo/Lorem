//
//  ALLRDroplet.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRDroplet.h"

@interface ALLRDroplet ()

- (instancetype)_init;

@end

@implementation ALLRDroplet

+ (instancetype)newDropletWithID:(NSUInteger)id{
    ALLRDroplet *droplet = [[self alloc] _init];
    droplet.id = id;
    //[droplet reloadStateWithCompletion:nil];
    return droplet;
}

- (instancetype)_init{
    self = [super init];
    return self;
}

- (void)reloadStateWithCompletion:(void (^)(BOOL))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]};
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu", (unsigned long)self.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(responseObject && [responseObject[@"status"] isEqualToString:@"OK"]){
            NSDictionary *drop = responseObject[@"droplet"];
            self.imageID = [drop[@"image_id"] isKindOfClass:[NSNull class]] ? 0 : [drop[@"image_id"] unsignedIntegerValue];
            self.IP = [drop[@"ip_address"] isKindOfClass:[NSNull class]] ? @"" : drop[@"ip_address"];
            self.locked = [drop[@"locked"] boolValue];
            self.name = [drop[@"name"] isKindOfClass:[NSNull class]] ? @"" : drop[@"name"];
            self.privateIP = [drop[@"private_ip_address"] isKindOfClass:[NSNull class]] ? @"" : drop[@"private_ip_address"];
            self.regionID = [drop[@"region_id"] isKindOfClass:[NSNull class]] ? 0 : [drop[@"region_id"] unsignedIntegerValue];
            self.sizeID = [drop[@"size_id"] isKindOfClass:[NSNull class]] ? 0 : [drop[@"size_id"] unsignedIntegerValue];
            self.status = [drop[@"status"] isKindOfClass:[NSNull class]] ? @"" : drop[@"status"];
            if(completion) completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        if(completion) completion(NO);
    }];
}

@end
