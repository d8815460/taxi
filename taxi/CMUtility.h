//
//  CMUtility.h
//  chatMessenger
//
//  Created by Ayi on 2014/3/4.
//  Copyright (c) 2014年 Ayi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMUtility : NSObject

+ (void)processFacebookProfilePictureData:(NSData *)data;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;

+ (void)sendFollowingPushNotification:(PFUser *)user;

//用戶有一個有效的Facebook數據
+ (BOOL)userHasValidFacebookData:(PFUser *)user;
//用戶有個人照片
+ (BOOL)userHasProfilePictures:(PFUser *)user;
//截取用戶的名字顯示在DisplayName上
+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

@end
