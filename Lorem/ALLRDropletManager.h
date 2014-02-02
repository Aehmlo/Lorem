//
//  ALLRDropletManager.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "ALLRCredentialManager.h"
#import "ALLRDroplet.h"

@interface ALLRDropletManager : NSObject{
    NSTimer *eventTimer;
}

+ (instancetype)sharedInstance;
+ (instancetype)sharedManager;

- (void)reloadDropletsWithCompletion:(void (^)(BOOL))completion;
- (void)renameDroplet:(ALLRDroplet *)droplet to:(NSString *)name completion:(void (^)(BOOL))completion;
- (void)powerOffDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion;
- (void)rebootDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion;
- (void)shutDownDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion;
- (void)bootDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion;

- (void)resizeDroplet:(ALLRDroplet *)droplet toSize:(NSUInteger)size completion:(void (^)(BOOL))completion;
- (void)takeSnapshotOfDroplet:(ALLRDroplet *)droplet withName:(NSString *)name completion:(void (^)(BOOL))completion;
- (void)resetRootPasswordForDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion;

- (void)destroyDroplet:(ALLRDroplet *)droplet completion:(void (^)(BOOL))completion; //Be very careful with this.

- (ALLRDroplet *)dropletWithID:(NSUInteger)id;

@property (nonatomic, retain) NSArray *droplets;

@end
