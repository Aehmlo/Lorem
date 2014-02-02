//
//  ALLRKeychainWrapper.h
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/31/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALLRKeychainWrapper : NSObject

- (id)initWithIdentifier:(NSString *)identifier accessGroup:(NSString *)accessGroup;
- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;

- (void)resetKeychainItem;

@end
