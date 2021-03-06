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
                        if(__success){
                            [self updateRegionsWithCompletion:^(BOOL ___success){
                                if(___success){
                                    [self updateSSHKeysWithCompletion:^(BOOL ___success){
                                        return;
                                    }];
                                }
                            }];
                        }
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

- (void)updateSSHKeysWithCompletion:(void (^)(BOOL success))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:@"https://api.digitalocean.com/ssh_keys" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if([responseObject[@"status"] isEqualToString:@"OK"]){
            self.SSHKeys = responseObject[@"ssh_keys"];
            if (completion) completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        completion(NO);
        NSLog(@"%@", error);
    }];
}

- (void)updateRegionsWithCompletion:(void (^)(BOOL success))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:@"https://api.digitalocean.com/regions" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if([responseObject[@"status"] isEqualToString:@"OK"]){
            self.regions = responseObject[@"regions"];
            if (completion) completion(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        completion(NO);
        NSLog(@"%@", error);
    }];
}

- (NSString *)sizeStringForSizeID:(NSUInteger)sizeID{
    for(NSDictionary *_size in self.sizes){
        if([_size[@"id"] unsignedIntegerValue]==sizeID) return [[_size[@"name"] stringByReplacingOccurrencesOfString:@"MB" withString:@" MB"] stringByReplacingOccurrencesOfString:@"GB" withString:@" GB"];
    }
    return @"Unknown";
}

- (NSString *)regionStringForRegionID:(NSUInteger)regionID{
    for(NSDictionary *_region in self.regions){
        if([_region[@"id"] unsignedIntegerValue]==regionID) return _region[@"name"];
    }
    return @"Unknown";
}

- (NSString *)imageStringForGlobalImageID:(NSUInteger)id{
    for(NSDictionary *_image in self.globalImages){
        if([_image[@"id"] unsignedIntegerValue]==id) return [_image[@"name"] stringByAppendingFormat:@" (%@)", _image[@"distribution"]];
    }
    return @"Unknown";
}

- (NSString *)nameForKeyID:(NSUInteger)keyID{
    if(keyID == 0) return @"None";
    for(NSDictionary *_key in self.SSHKeys){
        if([_key[@"id"] unsignedIntegerValue]==keyID) return _key[@"name"];
    }
    return @"Unknown";
}

- (NSUInteger)indexForSizeID:(NSUInteger)sizeID{
    for(NSUInteger i=0; i<[self.sizes count]; i++){
        if([self.sizes[i][@"id"] unsignedIntegerValue]==sizeID) return i;
    }
    return 0;
}

@end
