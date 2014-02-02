//
//  ALLRCredentialManager.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ALLRKeychainWrapper.h"
#import "ALLRMiscellaneousAPIInfoManager.h"

@interface ALLRCredentialManager : NSObject

+ (instancetype)sharedInstance;
+ (instancetype)sharedManager;

- (void)_setCredentials:(NSDictionary *)credentials completion:(void (^)(BOOL successful))completion;


- (BOOL)hasCredentials;
- (NSString *)clientID;
- (NSString *)APIKey;

@property (nonatomic, retain) ALLRKeychainWrapper *keychainWrapper;

@end
