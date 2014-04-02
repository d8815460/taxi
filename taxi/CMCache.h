//
//  CMCache.h
//  chatMessenger
//
//  Created by Ayi on 2014/3/5.
//  Copyright (c) 2014年 Ayi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMCache : NSObject

+ (id)sharedCache;

- (void)clear;


- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;

- (NSDictionary *)attributesForUser:(PFUser *)user;

- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;





@end
