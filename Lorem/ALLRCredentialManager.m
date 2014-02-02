//
//  ALLRCredentialManager.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRCredentialManager.h"

@implementation ALLRCredentialManager

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

- (instancetype)init{
    if ((self = [super init])){
        self.keychainWrapper = [[ALLRKeychainWrapper alloc] initWithIdentifier:@"com.aehmlo.lorem" accessGroup:nil];//@"com.aehmlo.lorem"];
        [self.keychainWrapper setObject:@"com.aehmlo.lorem.service" forKey:(__bridge id)kSecAttrService];
    }
    return self;
}

- (void)_setCredentials:(NSDictionary *)credentials completion:(void (^)(BOOL successful))completion{
    [self.keychainWrapper setObject:credentials[@"ClientID"] forKey:(__bridge id)kSecAttrAccount];
    [self.keychainWrapper setObject:credentials[@"APIKey"] forKey:(__bridge id)kSecAttrDescription];
    if(completion) completion(YES);
}

- (BOOL)hasCredentials{
    return ([self clientID] && ![[self clientID] isEqualToString:@""] && [self APIKey] && ![[self APIKey] isEqualToString:@""]);
}

- (NSString *)clientID{
    return [self.keychainWrapper objectForKey:(__bridge id)kSecAttrAccount];
    //return @"";
}

- (NSString *)APIKey{
    return [self.keychainWrapper objectForKey:(__bridge id)kSecAttrDescription];
    //return @"";
}

@end
