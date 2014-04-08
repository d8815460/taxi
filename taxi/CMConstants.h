//
//  CMConstants.h
//  chatMessenger
//
//  Created by Ayi on 2014/3/2.
//  Copyright (c) 2014年 Ayi. All rights reserved.
//

//個人資訊的key
extern NSString *const kCMUserNameString;
extern NSString *const defaultsFilterDistanceKey;
extern NSString *const defaultsLocationKey;
extern NSString *const kPAPParseLocationKey;
extern NSString *const kPAPUserTypeKey;
extern NSString *const kPAPUserIsReadLocationKey;

// Type values
extern NSString *const kPAPUserTypeDriverKey;
extern NSString *const kPAPUserTypePassengerKey;

// NSNotification userInfo keys:
extern NSString * const kPAWFilterDistanceKey;
extern NSString * const kPAWLocationKey;

// Notification names:
extern NSString * const kPAWFilterDistanceChangeNotification;
extern NSString * const kPAWLocationChangeNotification;

// Map Needs
extern double const kPAWFeetToMeters;                               // this is an exact value.
extern double const kPAWFeetToMiles;                                // this is an exact value.
extern double const kPAWWallPostMaximumSearchDistance;
extern double const kPAWMetersInAKilometer;                         // this is an exact value.

extern NSUInteger const kPAWMapCarsSearch;

#define PAWLocationAccuracy double

#pragma mark - Launch URLs
extern NSString *const kPAPLaunchURLHostTakePicture;                                //啟動URL主機拍照

#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPAPUserDisplayNameKey;
extern NSString *const kPAPUserFacebookIDKey;
extern NSString *const kPAPUserPhotoIDKey;
extern NSString *const kPAPUserProfilePicSmallKey;
extern NSString *const kPAPUserProfilePicMediumKey;
extern NSString *const kPAPUserFacebookFriendsKey;
extern NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kPAPUserPrivateChannelKey;
//facebook 生日、性別、email、地區、姓氏、名字
extern NSString *const kPAPUserFacebookBirthdayKey;
extern NSString *const kPAPUserFacebookGenderKey;
extern NSString *const kPAPUserFacebookEmailKey;
extern NSString *const kPAPUserFacebookLocalsKey;
extern NSString *const kPAPUserFacebookFirstNameKey;
extern NSString *const kPAPUserFacebookLastNameKey;
extern NSString *const kPAPUserFacebookLocation;
extern NSString *const kPAPUserMaxQuotaKey;
extern NSString *const kPAPUserFrequencyKey;


#pragma mark - PFObject User Location Class
// Class key
extern NSString *const kPAPUserLocationClassKey;
// Field keys
extern NSString *const kPAPUserLocationUserKey;
extern NSString *const kPAPUserLocationLocationKey;



// 個人檔案照片儲存位置
extern NSString * const MediumImagefilePath;
extern NSString * const SmallRoundedImagefilePath;

#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;    //用戶默認設置的活動資訊 - 視圖 - 控制器刷新鍵
extern NSString *const kPAPUserDefaultsHomeFeedViewControllerLastRefreshKey;        //首頁最後一次刷新鍵
extern NSString *const kPAPUserDefaultsMyQChannelFeedViewControllerLastRefreshKey;  //L2刷新鍵
extern NSString *const kPAPUserDefaultsMyQuestionFeedViewControllerLastRefreshKey;  //我的問題最後一次刷新鍵
extern NSString *const kPAPUserDefaultsMyAnswerFeedViewControllerLastRefreshKey;    //我的回答最後一次刷新鍵
extern NSString *const kPAPUserDefaultsAnnouncementFeedViewControllerLastRefreshKey;//公告最後一次刷新鍵
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;                     //用戶默認緩存給好友鍵
extern NSString *const kPAPUserDefaultsCacheQueryChannelsKey;                       //用戶默認緩存問題頻道鍵


#pragma mark - NSNotification
extern NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PAPUtilityUserFollowingChangedNotification;
extern NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPAPActivityClassKey;

// Field keys
extern NSString *const kPAPActivityTypeKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityContentKey;
extern NSString *const kPAPActivityPhotoKey;
extern NSString *const kPAPActivityIsReadedKey;

// Type values
extern int const kPAPActivityTypeComment;         //comment = 0
extern int const kPAPActivityTypeFollow;          //follow = 1
extern int const kPAPActivityTypeJoined;          //joined = 2
extern int const kPAPActivityTypeLike;            //like   = 3



#pragma mark - Cached User Attributes
// keys
extern NSString *const kPAPUserAttributesPhotoCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;

#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPAPPushPayloadPayloadTypeKey;
extern NSString *const kPAPPushPayloadPayloadTypeActivityKey;

extern NSString *const kPAPPushPayloadActivityTypeKey;
extern NSString *const kPAPPushPayloadActivityLikeKey;
extern NSString *const kPAPPushPayloadActivityCommentKey;
extern NSString *const kPAPPushPayloadActivityFollowKey;
extern NSString *const kPAPPushPayloadActivitySpanKey;

extern NSString *const kPAPPushPayloadFromUserObjectIdKey;
extern NSString *const kPAPPushPayloadToUserObjectIdKey;
extern NSString *const kPAPPushPayloadPhotoObjectIdKey;

#pragma mark - Installation Class

// Field keys
extern NSString *const kPAPInstallationUserKey;
extern NSString *const kPAPInstallationChannelsKey;

