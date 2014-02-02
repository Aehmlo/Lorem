//
//  ALLRDropletManager.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRDropletManager.h"

@implementation ALLRDropletManager

static id sharedManager;
static dispatch_once_t token;

+ (instancetype)sharedInstance{
    return [self sharedManager];
}

+ (instancetype)sharedManager{
    dispatch_once(&token, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)_reloadDroplets{
    [self reloadDropletsWithCompletion:nil];
}

- (instancetype)init{
    if((self = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reloadDroplets) name:@"com.aehmlo.lorem/reloadDroplets" object:nil];
    }
    return self;
}

- (ALLRDroplet *)dropletWithID:(NSUInteger)id{
    for(ALLRDroplet *droplet in self.droplets){
        if(droplet.id==id) return droplet;
    }
    return nil;
}

- (void)checkCompleted:(NSTimer *)timer{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Checking if completed (%lu)", (unsigned long)[[timer userInfo][@"Event"] unsignedIntegerValue]);
        if (![[timer userInfo][@"Event"] unsignedIntegerValue]){
            NSLog(@"Empty event. Invalidating.");
            [timer invalidate];
            return;
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                                 @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                                 };
        void (^completion)(BOOL) = ((void (^)(BOOL))[timer userInfo][@"Completion"]);
        NSUInteger event = [[timer userInfo][@"Event"] unsignedIntegerValue];
        NSLog(@"Timer is valid: %@", [timer isValid]?@"YES":@"NO");
        [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/events/%lu", (unsigned long)event] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
            if(operation.response.statusCode == 401){
                if(completion) completion(NO);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
                return;
            }
            else if(![responseObject[@"status"] isKindOfClass:[NSNull class]] && [responseObject[@"status"] isEqualToString:@"OK"] && ![responseObject[@"event"][@"percentage"] isKindOfClass:[NSNull class]] && [responseObject[@"event"][@"percentage"] integerValue]==100){
                NSLog(@"Should be invoking the completion block right about now...");
                if(completion) completion(YES);
                NSLog(@"Success!");
                [self invalidateTimer];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Strange error when requesting details for event %lu", (unsigned long)event);
            [self invalidateTimer];
        }];
    });
}

- (void)invalidateTimer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [eventTimer invalidate];
    });
}

- (void)invokeCompletion:(void (^)(BOOL))completion whenEventFinishes:(NSUInteger)event{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Setting up eventTimer.");
        eventTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkCompleted:) userInfo:@{@"Event": @(event), @"Completion": [completion copy]} repeats:YES];
    });
}

- (void)destroyDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/destroy", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){ //Snivel.
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if([responseObject[@"status"] isEqualToString:@"OK"]){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);}whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
        NSLog(@"%@", error);
    }];
}

- (void)takeSnapshotOfDroplet:(ALLRDroplet *)droplet withName:(NSString *)name completion:(void (^)(BOOL))completion{
    [self shutDownDroplet:droplet completion:^(BOOL _completion){
        if(!_completion){
            if(completion) completion(NO);
            return;
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        if(![[ALLRCredentialManager sharedManager] hasCredentials]){
            if(completion) completion(NO);
            return;
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[[[ALLRCredentialManager sharedManager] clientID], [[ALLRCredentialManager sharedManager] APIKey]] forKeys:@[@"client_id",@"api_key"]];
        if(name && ![name isEqualToString:@""] && [name rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]].location != NSNotFound){
            [params setObject:name forKey:@"name"];
        }
        [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/snapshot", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
            if(operation.response.statusCode == 401){
                if(completion) completion(NO);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
                return;
            }
            else if([responseObject[@"status"] isEqualToString:@"OK"]){
                droplet.locked = YES;
                [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);}whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            if(operation.response.statusCode == 401){
                if(completion) completion(NO);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            }
            NSLog(@"%@", error);
        }];
    }];
}

- (void)resizeDroplet:(ALLRDroplet *)droplet toSize:(NSUInteger)size completion:(void (^)(BOOL))completion{
    [self shutDownDroplet:droplet completion:^(BOOL _completion){
        if(!completion){
            if(completion) completion(NO);
            return;
        }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        if(![[ALLRCredentialManager sharedManager] hasCredentials]){
            if(completion) completion(NO);
            return;
        }
        NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                                 @"api_key": [[ALLRCredentialManager sharedManager] APIKey],
                                 @"size_id" : @(size)
                                 };
        [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/resize", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
            if(operation.response.statusCode == 401){
                if(completion) completion(NO);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
                return;
            }
            else if([responseObject[@"status"] isEqualToString:@"OK"]){
                droplet.locked = YES;
                [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);}whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            if(operation.response.statusCode == 401){
                if(completion) completion(NO);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            }
            NSLog(@"%@", error);
        }];
    }];
}

- (void)shutDownDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/shutdown", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if([responseObject[@"status"] isEqualToString:@"OK"]){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);}/*^(BOOL success){
                if(success) [self powerOffDroplet:droplet completion:completion];
            }*/ whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
        NSLog(@"%@", error);
    }];
}

- (void)powerOffDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/power_off", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if([responseObject[@"status"] isEqualToString:@"OK"]){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success); } whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
            NSLog(@"%@", error);
    }];
}

- (void)bootDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    [self powerOnDroplet:droplet completion:completion];
}

- (void)resetRootPasswordForDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    if(droplet.locked) completion(NO);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/password_reset", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if([responseObject[@"status"] isEqualToString:@"OK"]){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);} whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
        completion(NO);
    }];
}

- (void)powerOnDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    if(droplet.locked) return;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/power_on", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if([responseObject[@"status"] isEqualToString:@"OK"]){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);} whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
        NSLog(@"%@", error);
    }];
}

- (void)powerCycleDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
}

- (void)rebootDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion{
    if(droplet.locked) return;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]
                             };
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/reboot", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if([responseObject[@"status"] isEqualToString:@"OK"]){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);} whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
        NSLog(@"%@", error);
    }];
}

- (void)renameDroplet:(ALLRDroplet *)droplet to:(NSString *)name completion:(void (^)(BOOL))completion{
    if(droplet.locked) return;
    if([droplet.name isEqualToString:name]){
        if(completion) completion(YES);
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey],
                             @"name": name};
    [manager GET:[NSString stringWithFormat:@"https://api.digitalocean.com/droplets/%lu/rename", (unsigned long)droplet.id] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
            return;
        }
        else if(responseObject && [responseObject[@"status"] isEqualToString:@"OK"] && completion){
            droplet.locked = YES;
            [self invokeCompletion:^(BOOL success){droplet.locked = NO; if(completion) completion(success);} whenEventFinishes:[responseObject[@"event_id"] unsignedIntegerValue]];
        }
        else if(completion) completion(NO);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
            if(completion) completion(NO);
        }];
    
}

- (void)reloadDropletsWithCompletion:(void (^)(BOOL))completion{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(![[ALLRCredentialManager sharedManager] hasCredentials]){
        if(completion) completion(NO);
        return;
    }
    NSDictionary *params = @{@"client_id": [[ALLRCredentialManager sharedManager] clientID],
                             @"api_key": [[ALLRCredentialManager sharedManager] APIKey]};
    [manager GET:@"https://api.digitalocean.com/droplets" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(responseObject && [responseObject[@"status"] isEqualToString:@"OK"]){
            NSMutableArray *drops = [[NSMutableArray alloc] initWithCapacity:[[responseObject allKeys] count]-1];
            for(NSDictionary *drop in responseObject[@"droplets"]){
                ALLRDroplet *_drop = [ALLRDroplet newDropletWithID:[drop[@"id"] unsignedIntegerValue]];
                _drop.imageID = [drop[@"image_id"] isKindOfClass:[NSNull class]] ? 0 : [drop[@"image_id"] unsignedIntegerValue];
                _drop.IP = [drop[@"ip_address"] isKindOfClass:[NSNull class]] ? @"" : drop[@"ip_address"];
                _drop.locked = [drop[@"locked"] boolValue];
                _drop.name = [drop[@"name"] isKindOfClass:[NSNull class]] ? @"" : drop[@"name"];
                _drop.privateIP = [drop[@"private_ip_address"] isKindOfClass:[NSNull class]] ? @"" : drop[@"private_ip_address"];
                _drop.regionID = [drop[@"region_id"] isKindOfClass:[NSNull class]] ? 0 : [drop[@"region_id"] unsignedIntegerValue];
                _drop.sizeID = [drop[@"size_id"] isKindOfClass:[NSNull class]] ? 0 : [drop[@"size_id"] unsignedIntegerValue];
                _drop.status = [drop[@"status"] isKindOfClass:[NSNull class]] ? @"" : drop[@"status"];
                [drops addObject:_drop];
            }
            self.droplets = [[NSArray alloc] initWithArray:drops]; //We do not want this to be mutable, as we want everything to be verified through checking the API.
            drops = nil;
            if(completion) completion(YES);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/dropletManagerDidUpdate" object:nil ];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if(operation.response.statusCode == 401){
            if(completion) completion(NO);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.aehmlo.lorem/loginRequired" object:nil];
        }
        if(completion) completion(NO);
    }];
}

@end
