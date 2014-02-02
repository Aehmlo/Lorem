//
//  ALLRMiscellaneousAPIInfoManager.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRMiscellaneousAPIInfoManager.h"

@implementation ALLRMiscellaneousAPIInfoManager

static ALLRMiscellaneousAPIInfoManager *sharedManager; //Wow, that's a mouthful.

+ (instancetype)sharedInstance{
    return [self sharedManager];
}

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager updateAll];
    });
    return sharedManager;
}

- (void)updateAll{
    [self updateSizesWithCompletion:^(BOOL success){
        if(success){
            [self updateMyImagesWithCompletion:^(BOOL _success){
                if(_success){
                    [self updateGlobalImagesWithCompletion:^(BOOL __success){
                        return;
                    }];
                }
            }];
        }
    }];
}

- (void)updateMyImagesWithCompletion:(void (^)(BOOL success))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey],
                             @"filter": @"my_images"
                             };
    [manager GET:@"https://api.digitalocean.com/images" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if([responseObject[@"status"] isEqualToString:@"OK"]){
            self.myImages = responseObject[@"images"];
            if (completion) completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        completion(NO);
        NSLog(@"%@", error);
    }];
}

- (void)updateGlobalImagesWithCompletion:(void (^)(BOOL success))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey],
                             @"filter": @"global"
                             };
    [manager GET:@"https://api.digitalocean.com/images" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if([responseObject[@"status"] isEqualToString:@"OK"]){
            self.globalImages = responseObject[@"images"];
            if (completion) completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        completion(NO);
        NSLog(@"%@", error);
    }];
}

- (void)updateSizesWithCompletion:(void (^)(BOOL success))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:@"https://api.digitalocean.com/sizes" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if([responseObject[@"status"] isEqualToString:@"OK"]){
            self.sizes = responseObject[@"sizes"];
            if (completion) completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        completion(NO);
        NSLog(@"%@", error);
    }];
}

@end
