//
//  CMConstants.m
//  chatMessenger
//
//  Created by Ayi on 2014/3/2.
//  Copyright (c) 2014年 Ayi. All rights reserved.
//

#import "CMConstants.h"

//natalielin1985
#pragma mark - 個人資訊的key
NSString *const kCMUserNameString           = @"username";
NSString *const defaultsFilterDistanceKey   = @"filterDistance";
NSString *const defaultsLocationKey         = @"currentLocation";
NSString *const kPAWParseLocationKey        = @"location";

#pragma mark - NSNotification userInfo keys:
NSString * const kPAWFilterDistanceKey = @"filterDistance";
NSString * const kPAWLocationKey = @"location";


#pragma mark - Notification names:
NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";

#pragma mark - Map Needs
double const kPAWFeetToMeters = 0.3048;                                 // this is an exact value.
double const kPAWFeetToMiles = 5280.0;;                                 // this is an exact value.
double const kPAWWallPostMaximumSearchDistance = 3.0;
double const kPAWMetersInAKilometer = 1000.0;                           // this is an exact value.

#pragma mark - Launch URLs
NSString *const kPAPLaunchURLHostTakePicture = @"camera";

#pragma mark - User Class
// Field keys
NSString *const kPAPUserDisplayNameKey                          = @"displayName";
NSString *const kPAPUserFacebookIDKey                           = @"facebookId";
NSString *const kPAPUserPhotoIDKey                              = @"photoId";
NSString *const kPAPUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kPAPUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kPAPUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kPAPUserPrivateChannelKey                       = @"channel";
//資料表新增生日、性別、email、地區、姓氏、名字
NSString *const kPAPUserFacebookBirthdayKey                     = @"birthday";
NSString *const kPAPUserFacebookGenderKey                       = @"gender";
NSString *const kPAPUserFacebookEmailKey                        = @"email";
NSString *const kPAPUserFacebookLocalsKey                       = @"fbLocale";
NSString *const kPAPUserFacebookFirstNameKey                    = @"fbFirstName";
NSString *const kPAPUserFacebookLastNameKey                     = @"fbLastName";
NSString *const kPAPUserMaxQuotaKey                             = @"userMaxQuota";
NSString *const kPAPUserFrequencyKey                            = @"frequency";


#pragma mark - PFObject User Location Class
// Class key
NSString *const kPAPUserLocationClassKey        = @"UserLocation";
// Field keys
NSString *const kPAPUserLocationUserKey         = @"user";
NSString *const kPAPUserLocationLocationKey     = @"location";




//個人檔案照片儲存位置
NSString * const MediumImagefilePath = @"Documents/medium.png";
NSString * const SmallRoundedImagefilePath = @"Documents/small.png";

#pragma mark - NSUserDefaults
NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.ayiapp.Wheels.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsHomeFeedViewControllerLastRefreshKey        = @"com.ayiapp.Wheels.userDefaults.HomeFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsMyQChannelFeedViewControllerLastRefreshKey  = @"com.ayiapp.Wheels.userDefaults.MyQChannelFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsMyQuestionFeedViewControllerLastRefreshKey  = @"com.ayiapp.Wheels.userDefaults.MyQuestionFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsMyAnswerFeedViewControllerLastRefreshKey    = @"com.ayiapp.Wheels.userDefaults.MyAnswerFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsAnnouncementFeedViewControllerLastRefreshKey= @"com.ayiapp.Wheels.userDefaults.AnnouncementFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.ayiapp.Wheels.userDefaults.cache.facebookFriends";
NSString *const kPAPUserDefaultsCacheQueryChannelsKey                       = @"com.ayiapp.Wheels.queryChannels.cache.Channels";



#pragma mark - NSNotification

NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification           = @"com.ayiapp.Wheels.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PAPUtilityUserFollowingChangedNotification                      = @"com.ayiapp.Wheels.utility.userFollowingChanged";
NSString *const PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.ayiapp.Wheels.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"com.ayiapp.Wheels.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingPhotoNotification            = @"com.ayiapp.Wheels.tabBarController.didFinishEditingPhoto";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"com.ayiapp.Wheels.tabBarController.didFinishImageFileUploadNotification";
NSString *const PAPPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.ayiapp.Wheels.photoDetailsViewController.userDeletedPhoto";
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.ayiapp.Wheels.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.ayiapp.Wheels.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";


#pragma mark - Activity Class
// Class key
NSString *const kPAPActivityClassKey = @"Activity";

// Field keys
NSString *const kPAPActivityTypeKey        = @"type";
NSString *const kPAPActivityFromUserKey    = @"fromUser";
NSString *const kPAPActivityToUserKey      = @"toUser";
NSString *const kPAPActivityContentKey     = @"content";
NSString *const kPAPActivityPhotoKey       = @"photo";
NSString *const kPAPActivityIsReadedKey    = @"isReaded";

// Type values
int const kPAPActivityTypeComment    = 0;             //0 = comment
int const kPAPActivityTypeFollow     = 1;             //1 = follow
int const kPAPActivityTypeJoined     = 2;             //2 = joined
int const kPAPActivityTypeLike       = 3;             //3 = like


#pragma mark - Cached User Attributes
// keys
NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
// 下面的鍵被故意盡量短，APNS的最大有效載荷限制
NSString *const kPAPPushPayloadPayloadTypeKey          = @"p";
NSString *const kPAPPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPAPPushPayloadActivityTypeKey     = @"t";
NSString *const kPAPPushPayloadActivityLikeKey     = @"l";
NSString *const kPAPPushPayloadActivityCommentKey  = @"c";
NSString *const kPAPPushPayloadActivityFollowKey   = @"f";
NSString *const kPAPPushPayloadActivitySpanKey     = @"s";

NSString *const kPAPPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPAPPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPAPPushPayloadPhotoObjectIdKey    = @"pid";



#pragma mark - Installation Class

// Field keys
NSString *const kPAPInstallationUserKey = @"user";
NSString *const kPAPInstallationChannelsKey = @"channels";




