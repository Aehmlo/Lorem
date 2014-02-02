//
//  ALLRDroplet.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/27/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"
#import "ALLRCredentialManager.h"

@interface ALLRDroplet : NSObject

+ (instancetype)newDropletWithID:(NSUInteger)id;

- (id)init __attribute__((unavailable("Please use +[ALLRDroplet newDropletWithID:] instead.")));
- (void)reloadStateWithCompletion:(void (^)(BOOL))completion;

@property (nonatomic) NSUInteger id;                        //id
@property (nonatomic) NSUInteger imageID;                   //image_id
@property (nonatomic, retain) NSString *name;               //name
@property (nonatomic) NSInteger regionID;                   //region_id
@property (nonatomic) NSInteger sizeID;                     //size_id
@property (nonatomic) BOOL backupsActive;                   //backups_active
@property (nonatomic, retain) NSArray *backups;             //backups
@property (nonatomic, retain) NSArray *snapshots;           //snapshots
@property (nonatomic, retain) NSString *IP;                 //ip_address
@property (nonatomic, retain) NSString *privateIP;          //private_ip_address
@property (nonatomic) BOOL locked;                          //locked
@property (nonatomic, retain) NSString *status;             //status

@end
