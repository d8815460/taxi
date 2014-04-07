//
//  AppDelegate.m
//  taxi
//
//  Created by Ayi on 2014/4/1.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//
#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "AppDelegate.h"
#import "SDKDemoAPIKey.h"
#import "GoogleMapViewController.h"
#import "AyiWellcomeViewController.h"
#import "SetProfileViewController.h"

static AppDelegate *sharedDelegate;


@implementation AppDelegate{
    id services_;
}
@synthesize hostReach       = _hostReach;                   //判斷網路是否可用
@synthesize internetReach   = _internetReach;               //判斷網路是否可用
@synthesize wifiReach       = _wifiReach;                   //判斷wifi網路是否可用
@synthesize networkStatus;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // ****************************************************************************
    // Parse initialization
    // [Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY"];
    //
    // Make sure to update your URL scheme to match this facebook id. It should be "fbFACEBOOK_APP_ID" where FACEBOOK_APP_ID is your Facebook app's id.
    // You may set one up at https://developers.facebook.com/apps
    // [PFFacebookUtils initializeWithApplicationId:@"FACEBOOK_APP_ID"];
    // ****************************************************************************
    
    [Parse setApplicationId:@"jQApO3abx7F3qf1htx9ZTnoP8bjjclY64g8DWtkS"
                  clientKey:@"0a9phtoy1RN0tRjBQIMMOQzkpBJTEDdIwRUlsrp1"];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"XRHzv2XCnOD4CpjNwbmdjjxpV"
                               consumerSecret:@"K0CyoMPKkyQSva1WseNxCFbyBDkWFb52ALNielz16qh0cLA48r"];
    

    //設定GoogleMap的API key
    if ([kAPIKey length] == 0) {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKey inside SDKDemoAPIKey.h for your "
        @"bundle `%@`, see README.GoogleMapsSDKDemos for more information";
        @throw [NSException exceptionWithName:@"SDKDemoAppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    [GMSServices provideAPIKey:kAPIKey];
    services_ = [GMSServices sharedServices];
    
    // Log the required open source licenses!  Yes, just NSLog-ing them is not
    // enough but is good for a demo.
    NSLog(@"Open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);
    
    
    if (application.applicationIconBadgeNumber != 0) {
        NSLog(@"install 1");
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Use Reachability to monitor connectivity
    // 偵測網路是否正常
    [self monitorReachability];
    
    
    
    
    //如果當前用戶已經登入，直接跳過WelcomeView，來到GoogleMap
    if (![PFUser currentUser]) {
        
    }else{
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UINavigationController *mapView = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"mapNavigation"];
        self.window.rootViewController = mapView;
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

// ****************************************************************************
// 應用程序切換方法，以支持Facebook單點登錄
// ****************************************************************************
// Facebook oauth callback
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBAppCall handleOpenURL:url sourceApplication:nil withSession:[PFFacebookUtils session]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark - 推播用到DeviceToken。
/*
 *啟用的條件，需要在接收推播的ViewController加入
 *[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge| UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
 */

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [PFPush storeDeviceToken:deviceToken];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    NSLog(@"install 2");
    
    //    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:kPAPInstallationChannelsKey];
    if ([PFUser currentUser]) {
        // Make sure they are subscribed to their private push channel
        NSString *privateChannelName = [[PFUser currentUser] objectForKey:kPAPUserPrivateChannelKey];
        if (privateChannelName && privateChannelName.length > 0) {
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey];
        }
    }
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

#pragma mark - 收到推播訊息，在背景情況或未開啓App收到推播要做的事情
- (void)handlePushUserInfo:(NSDictionary *)userInfo {
    if ([UIApplication sharedApplication].applicationIconBadgeNumber != 0) {
        //未讀通知數量歸零
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    // 如果推出推送通知的應用程序，我們將在這裡處理的有效載荷
    NSLog(@"userInfo PayLoad here is = %@", userInfo);
    if (userInfo) {
        //do something
    }
}

#pragma mark - 收到推播訊息，在前景運行中的App收到推播要做的事情
- (void)handlePush:(NSDictionary *)launchOptions{
    if ([UIApplication sharedApplication].applicationIconBadgeNumber != 0) {
        //未讀通知數量歸零
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    // If the app was launched in response to a push notification, we'll handle the payload here
    // 如果推出推送通知的應用程序，我們將在這裡處理的有效載荷
    NSLog(@"launchOptions PayLoad here is = %@", launchOptions);
    
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    NSString *pushInfo = [NSString stringWithFormat:@"%@",[remoteNotificationPayload objectForKey:@"aps"]];
    NSLog(@"PushInfo here is = %@", pushInfo);
    
    if (remoteNotificationPayload) {
        // do something.
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    //發送時，該應用程序將要由積極轉移到非活動狀態。這可能會發生某些類型的暫時中斷的（例如呼入電話呼叫或SMS消息），或者當用戶退出應用程序和它開始過渡到背景狀態。
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //使用這個方法來暫停正在進行的任務，禁用定時器，並踩下油門，OpenGL ES的幀速率。遊戲應該使用這個方法來暫停遊戲。
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    //使用這個方法來釋放共享資源，保存用戶數據，無效計時器，並儲存足夠的應用程序狀態信息到應用程序恢復的情況下其目前的狀態是後終止。
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //如果你的應用程序支持後台運行，這種方法被稱為代替applicationWillTerminate：當用戶退出。
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [currentUser setObject:@NO forKey:kPAPUserIsReadLocationKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        currentUser.ACL = ACL;
        
        [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
            
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //調用從背景到非活動狀態的轉變的一部分，在這裡您可以撤消許多就進入背景的變化。
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //重新啟動已暫停（或尚未開始），而應用程序是無效的任何任務。如果應用程序是以前的背景下，選擇性地刷新用戶界面。
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        NSLog(@"install 3");
        [[PFInstallation currentInstallation] saveEventually];
    }
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
    
    // Handle an interruption during the authorization flow, such as the user clicking the home button.
    //授權流程，如點擊home鍵，用戶在處理中斷。
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // 當應用程序即將終止調用。如果適當的保存數據。另請參閱applicationDidEnterBackground：
}

+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

+ (AppDelegate *)sharedDelegate {
    if (!sharedDelegate) {
        sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return sharedDelegate;
}


#pragma mark - setupAppearance 自定樣式
- (void)setupAppearance {
    
}

#pragma mark - monitorReachability 偵測網路是否正常運作
- (void)monitorReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    [self.hostReach startNotifier];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    
    self.wifiReach = [Reachability reachabilityForLocalWiFi];
    [self.wifiReach startNotifier];
}

#pragma mark - 網路訊號改變
//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification* )note {
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NSLog(@"Reachability changed: %@", curReach);
    networkStatus = [curReach currentReachabilityStatus];
    
    /*
     有網路情況下，重新載入物件的方法
     */
    //    if ([self isParseReachable] && [PFUser currentUser] && self.paphomeViewController.objects.count == 0) {
    //        // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
    //        // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
    //        [self.paphomeViewController loadObjects];
    //    }
}

#pragma mark - isParseReachable
- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}
#pragma mark - presentWelcomeViewControllerAnimated
- (void)presentWelcomeViewControllerAnimated:(BOOL)animated {
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    AyiWellcomeViewController *welcomeVC = (AyiWellcomeViewController *)[storybord instantiateViewControllerWithIdentifier:@"welcome"];
    self.window.rootViewController = welcomeVC;
}
#pragma mark - presentWelcomeViewController
- (void)presentWelcomeViewController {
    [self presentWelcomeViewControllerAnimated:YES];
}

#pragma mark - 第一次登入轉場至會員第一次設定頁
- (void)presentFirstSignInViewController{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SetProfileViewController *firstSign = (SetProfileViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"setProfile"];
    firstSign.navigationItem.leftBarButtonItem = nil;
    self.window.rootViewController = firstSign;
    [self.window makeKeyAndVisible];
}
#pragma mark - 轉場至Google Map
- (void)presentGoogleMapController {
    UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *googleMap = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"mapNavigation"];
    self.window.rootViewController = googleMap;
    [self.window makeKeyAndVisible];
}

#pragma mark - 登出
- (void)logOut{
    // clear cache
    [[CMCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"install 4");
    [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] removeObjectForKey:@"channels"];
    [[PFInstallation currentInstallation] removeObjectForKey:@"deviceToken"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    //要把用戶名稱刪除
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kCMUserNameString];
    [userDefaults removeObjectForKey:@"mediumImage"];
    [userDefaults removeObjectForKey:@"smallRoundedImage"];
    [userDefaults synchronize];
    [PFUser logOut];
    
    [self presentWelcomeViewController];
}

- (BOOL)handleActionURL:(NSURL *)url {
    if ([[url host] isEqualToString:kPAPLaunchURLHostTakePicture]) {
        if ([PFUser currentUser]) {
            //偵測到拍照動作，就轉場至Ask畫面的拍照按鈕
            /*
             這裡原先的拍照按鈕剛好等於tabBar的中間鈕，所以現在就暫時取消。
             return [self.tabBarController shouldPresentPhotoCaptureController];
             */
        }
    }
    return NO;
}
@end
