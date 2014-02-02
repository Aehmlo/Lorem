//
//  ALLRKeychainWrapper.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/31/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

//Thanks to https://gist.github.com/dhoerl/1170641

#import "ALLRKeychainWrapper.h"

@interface ALLRKeychainWrapper (){
    NSMutableDictionary *keychainItemData;		// The actual keychain item data backing store.
    NSMutableDictionary *genericPasswordQuery;	// A placeholder for the generic keychain item query used to locate the item.
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;

//Updates the item in the keychain, or creates it if it doesn't exist.
- (void)writeToKeychain;

@end

@implementation ALLRKeychainWrapper

- (id)initWithIdentifier:(NSString *)identifier accessGroup:(NSString *)accessGroup{
    if((self = [super init])){
        // Begin Keychain search setup. The genericPasswordQuery leverages the special user
        // defined attribute kSecAttrGeneric to distinguish itself between other generic Keychain
        // items which may be included by the same application.
        genericPasswordQuery = [[NSMutableDictionary alloc] init];
        
		[genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [genericPasswordQuery setObject:identifier forKey:(__bridge id)kSecAttrGeneric];
		
		// The keychain access group attribute determines if this item can be shared
		// amongst multiple apps whose code signing entitlements contain the same keychain access group.
		if(accessGroup != nil){
#if TARGET_IPHONE_SIMULATOR
			// Ignore the access group if running on the iPhone simulator.
			//
			// Apps that are built for the simulator aren't signed, so there's no keychain access group
			// for the simulator to check. This means that all apps can see all keychain items when run
			// on the simulator.
			//
			// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
			// simulator will return -25243 (errSecNoAccessForItem).
#else
			[genericPasswordQuery setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
		}
		
		// Use the proper search constants, return only the attributes of the first match.
        [genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
        
        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:genericPasswordQuery];
        
        CFMutableDictionaryRef outDictionary = NULL;
        
        if(!SecItemCopyMatching((__bridge CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary) == noErr){
            // Stick these default values into keychain item if nothing found.
            [self resetKeychainItem];
			
			// Add the generic attribute and the keychain access group.
			[keychainItemData setObject:identifier forKey:(__bridge id)kSecAttrGeneric];
			if(accessGroup != nil){
#if TARGET_IPHONE_SIMULATOR
				// Ignore the access group if running on the iPhone simulator.
				//
				// Apps that are built for the simulator aren't signed, so there's no keychain access group
				// for the simulator to check. This means that all apps can see all keychain items when run
				// on the simulator.
				//
				// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
				// simulator will return -25243 (errSecNoAccessForItem).
#else
				[keychainItemData setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
			}
		}
        else{
            // load the saved data from Keychain.
            keychainItemData = [self secItemFormatToDictionary:(__bridge NSDictionary *)outDictionary];
        }
		if(outDictionary) CFRelease(outDictionary);
    }
    
	return self;
}

- (void)setObject:(id)inObject forKey:(id)key{
    if(inObject == nil) return;
    id currentObject = [keychainItemData objectForKey:key];
    if(![currentObject isEqual:inObject]){
        [keychainItemData setObject:inObject forKey:key];
        [self writeToKeychain];
    }
}

- (id)objectForKey:(id)key{
    return [keychainItemData objectForKey:key];
}

- (void)resetKeychainItem{
    if(!keychainItemData){
        keychainItemData = [[NSMutableDictionary alloc] init];
    }else if (keychainItemData){
        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:keychainItemData];
#ifndef NS_BLOCK_ASSERTIONS
		OSStatus junk =
#endif
        SecItemDelete((__bridge CFDictionaryRef)tempDictionary);
        NSAssert( junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary." );
    }
    
    // Default attributes for keychain item.
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecAttrAccount];
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecAttrLabel];
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecAttrDescription];
    
	// Default data for keychain item.
#ifndef PASSWORD_USES_DATA
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecValueData];
#else
    [keychainItemData setObject:[NSData data] forKey:(__bridge id)kSecValueData];
#endif
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert{
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for a SecItem.
    
    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the Generic Password keychain item class attribute.
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Convert the NSString to NSData to meet the requirements for the value type kSecValueData.
	// This is where to store sensitive data that should be encrypted.
#ifndef PASSWORD_USES_DATA
	// orig
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
#else
	// DFH
    id val = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
	if([val isKindOfClass:[NSString class]]){
		val = [(NSString *)val dataUsingEncoding:NSUTF8StringEncoding];
	}
    [returnDictionary setObject:val forKey:(__bridge id)kSecValueData];
#endif
    
    
    return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert{
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for the UI element.
    
    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the proper search key and class attribute.
    [returnDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Acquire the password data from the attributes.
    CFDataRef passwordData = NULL;
    if(SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData) == noErr){
        // Remove the search, class, and identifier key/value, we don't need them anymore.
        [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
        
#ifndef PASSWORD_USES_DATA
        // Add the password to the dictionary, converting from NSData to NSString.
        NSString *password = [[NSString alloc] initWithBytes:[(__bridge NSData *)passwordData bytes] length:[(__bridge NSData *)passwordData length]
                                                    encoding:NSUTF8StringEncoding];
#else
		NSData *password = (__bridge_transfer NSData *)passwordData;
		passwordData = NULL;
#endif
        [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
    }else{
        // Don't do anything if nothing is found.
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }
	if(passwordData) CFRelease(passwordData);
    
	return returnDictionary;
}

- (void)writeToKeychain{
    CFDictionaryRef attributes = NULL;
    NSMutableDictionary *updateItem = nil;
	OSStatus result;
    
    if(SecItemCopyMatching((__bridge CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&attributes) == noErr){
        // First we need the attributes from the Keychain.
        updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)attributes];
        // Second we need to add the appropriate search key/values.
        [updateItem setObject:[genericPasswordQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        
        // Lastly, we need to set up the updated attribute list being careful to remove the class.
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:keychainItemData];
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];
		
#if TARGET_IPHONE_SIMULATOR
		// Remove the access group if running on the iPhone simulator.
		//
		// Apps that are built for the simulator aren't signed, so there's no keychain access group
		// for the simulator to check. This means that all apps can see all keychain items when run
		// on the simulator.
		//
		// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
		// simulator will return -25243 (errSecNoAccessForItem).
		//
		// The access group attribute will be included in items returned by SecItemCopyMatching,
		// which is why we need to remove it before updating the item.
		[tempCheck removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
        
        // An implicit assumption is that you can only update a single item at a time.
#ifndef NDEBUG
        result =
#endif
        SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)tempCheck);
        
		NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    }else{
        // No previous item found; add the new one.
        result = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:keychainItemData], NULL);
		NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
    }
	
	if(attributes) CFRelease(attributes);
}

@end