//
//  CMUtility.m
//  chatMessenger
//
//  Created by Ayi on 2014/3/4.
//  Copyright (c) 2014年 Ayi. All rights reserved.
//

#import "CMUtility.h"
#import "UIImage+ResizeAdditions.h"

@implementation CMUtility


#pragma mark Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        NSLog(@"個人照片無法成功下載。");
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    //如果檔案照片一致就不需要再重新上傳。
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
    //        // We have a cached Facebook profile picture
    //
    //        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
    //
    //        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
    //            NSLog(@"緩存的個人檔案照片與資料庫上一致，系統將不會更新照片檔案。");
    //            return;
    //        }
    //    }
    
    BOOL cachedToDisk = [[NSFileManager defaultManager] createFileAtPath:[profilePictureCacheURL path] contents:newProfilePictureData attributes:nil];
    NSLog(@"磁碟高速緩存個人檔案照片: %d", cachedToDisk);
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:140 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:32 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImagePNGRepresentation(mediumImage); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:UIImagePNGRepresentation(mediumImage) forKey:@"mediumImage"];
    [userDefaults setObject:UIImagePNGRepresentation(smallRoundedImage) forKey:@"smallRoundedImage"];
    [userDefaults synchronize];
    
    //创建文件管理器
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    // 创建profile目录 //在Documents里创建目录
//    NSString *profileDirectory = [documentsDirectory stringByAppendingPathComponent:@"profile"];
//    [fileManager createDirectoryAtPath:profileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
//    //更改到待操作的目录下
//    [fileManager changeCurrentDirectoryPath:[profileDirectory stringByExpandingTildeInPath]];
//    //在profile目录下创建文件
//    NSString *profileMediumPath = [profileDirectory stringByAppendingPathComponent:@"medium.png"];
//    NSString *profileSmallPath = [profileDirectory stringByAppendingPathComponent:@"small.png"];
//    //寫入檔案
//    [fileManager createFileAtPath:profileMediumPath contents:mediumImageData attributes:nil];
//    [fileManager createFileAtPath:profileSmallPath contents:smallRoundedImageData attributes:nil];
    
    //讀取檔案
    //    NSData *reader = [NSData dataWithContentsOfFile:path];
    /*
     其他地方可以用這個方法去取回當前用戶的大頭照。
     NSData *mediumimageData = [NSData dataWithContentsOfFile:mediumpath];
     NSData *smallimageData = [NSData dataWithContentsOfFile:smallpath];
     */
    
    if (mediumImageData.length > 0) {
        NSLog(@"中型個人檔案照片上載中...");
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"中型個人檔案照片上載完成。");
                PFUser *currentMyFile = [PFUser currentUser];
                [currentMyFile setObject:fileMediumImage forKey:kPAPUserProfilePicMediumKey];
                [currentMyFile saveEventually:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"中型個人檔案照片應該要確實上傳到資料庫。");
                    }else {
                        NSLog(@"中型個人檔案照片出錯囉！");
                    }
                    
                }];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
        NSLog(@"小型個人檔案照片上載中...");
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"小型個人檔案照片上載完成。");
                PFUser *currentMyFile = [PFUser currentUser];
                [currentMyFile setObject:fileSmallRoundedImage forKey:kPAPUserProfilePicSmallKey];
                [currentMyFile saveEventually:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"小型個人檔案照片應該要確實上傳到資料庫。");
                    }else{
                        NSLog(@"小型個人檔案照片出錯囉！");
                    }
                }];
            }
        }];
    }
}



#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:[NSNumber numberWithInt:kPAPActivityTypeFollow] forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
        
        if (succeeded) {
            //            [PAPUtility sendFollowingPushNotification:user];  移除好友安裝wheels的推播。
        }
    }];
    [[CMCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
    [followActivity setObject:user forKey:kPAPActivityToUserKey];
    [followActivity setObject:[NSNumber numberWithInt:kPAPActivityTypeFollow] forKey:kPAPActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[CMCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [CMUtility followUserEventually:user block:completionBlock];
        [[CMCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey equalTo:user];
    [query whereKey:kPAPActivityTypeKey equalTo:[NSNumber numberWithInt:kPAPActivityTypeFollow]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[CMCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityToUserKey containedIn:users];
    [query whereKey:kPAPActivityTypeKey equalTo:[NSNumber numberWithInt:kPAPActivityTypeFollow]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[CMCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Push
+ (void)sendFollowingPushNotification:(PFUser *)user {
    NSString *privateChannelName = [user objectForKey:kPAPUserPrivateChannelKey];
    if (privateChannelName && privateChannelName.length != 0) {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:NSLocalizedStringFromTable( @"notifyFriendInstall", @"InfoPlist" , @"推播訊息" ), [CMUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]]], kAPNSAlertKey,
                              kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                              kPAPPushPayloadActivityFollowKey, kPAPPushPayloadActivityTypeKey,
                              [[PFUser currentUser] objectId], kPAPPushPayloadFromUserObjectIdKey,
                              nil];
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:privateChannelName];
        [push setData:data];
        [push sendPushInBackground];
    }
}


+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kPAPUserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kPAPUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kPAPUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"某人";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}

@end
