//
//  ALLRMiscellaneousAPIInfoManager.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ALLRCredentialManager.h"
#import "AFHTTPRequestOperationManager.h"

@interface ALLRMiscellaneousAPIInfoManager : NSObject

+ (instancetype)sharedInstance;
+ (instancetype)sharedManager;

- (void)updateAll;
- (void)updateSizesWithCompletion:(void (^)(BOOL success))completion;
- (void)updateMyImagesWithCompletion:(void (^)(BOOL success))completion;
- (void)updateGlobalImagesWithCompletion:(void (^)(BOOL success))completion;

- (NSString *)sizeStringForSizeID:(NSUInteger)sizeID;
- (NSUInteger)indexForSizeID:(NSUInteger)sizeID;

@property (nonatomic, retain) NSArray *sizes;
@property (nonatomic, retain) NSArray *myImages;
@property (nonatomic, retain) NSArray *globalImages;
@property (nonatomic, retain) NSArray *SSHKeys;

@end
