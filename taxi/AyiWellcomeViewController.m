//
//  AyiWellcomeViewController.m
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import "AyiWellcomeViewController.h"
#import <MBProgressHUD.h>
#import "AppDelegate.h"

@interface AyiWellcomeViewController (){
    NSMutableData *_data;   //FB之照片資料
    BOOL firstLaunch;
}
@property (nonatomic, strong) MBProgressHUD *hud;                               //Alert
@property (nonatomic, strong) NSTimer *autoFollowTimer;                         //定時器追蹤朋友Follow
@end

@implementation AyiWellcomeViewController
@synthesize loginViewController = _loginViewController;
@synthesize signupViewController = _signupViewController;
@synthesize hud = _hud;
@synthesize autoFollowTimer = _autoFollowTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _loginViewController = [[AyiLoginViewController alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"login" sender:sender];
}

- (IBAction)signupButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"signup" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"login"]) {
        // Customize the Log In View Controller
        UINavigationController *navigationController = segue.destinationViewController;
        NSArray *viewControllers = navigationController.viewControllers;
        _loginViewController = viewControllers[0];
        _loginViewController.delegate = self;
        _loginViewController.facebookPermissions = @[@"friends_about_me"];
        _loginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsPasswordForgotten;
    }else if ([segue.identifier isEqualToString:@"signup"]){
        UINavigationController *navigationController = segue.destinationViewController;
        NSArray *viewControllers = navigationController.viewControllers;
        _signupViewController = viewControllers[0];
        _signupViewController.delegate = self;
        _signupViewController.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsAdditional | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton;
        
    }
}

#pragma mark - PFSignUpViewControllerDelegate

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info{
    
    BOOL informationComplete = YES;
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }else{
        //註冊成功了才前往下一步。
        [signUpController performSegueWithIdentifier:@"setProfile" sender:nil];
    }
    
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"註冊用戶為 %@", user);
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


#pragma mark - PFLogInViewControllerDelegate
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
    [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey];
    [[PFInstallation currentInstallation] saveEventually];
    
    if ([user isNew]) {
        //先判斷是不是facebook 登入，如果是，就要記錄用戶資料
        if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
            // If user is linked to Twitter, we'll use their Twitter screen name
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            //儲存用戶名稱
            [userDefaults setValue:[PFTwitterUtils twitter].screenName forKey:kCMUserNameString];
            [userDefaults setValue:privateChannelName forKey:kPAPUserPrivateChannelKey];
            [userDefaults synchronize];
            
            [[PFUser currentUser] setObject:privateChannelName forKey:kPAPUserPrivateChannelKey];
            [[PFUser currentUser] setObject:[PFTwitterUtils twitter].screenName forKey:kPAPUserDisplayNameKey];
            
            PFACL *ACL = [PFACL ACL];
            [ACL setPublicReadAccess:YES];
            [PFUser currentUser].ACL = ACL;
            
            [[PFUser currentUser] saveEventually];
            
        } else if ([PFFacebookUtils isLinkedWithUser:user]) {
            // If user is linked to Facebook, we'll use the Facebook Graph API to fetch their full name. But first, show a generic Welcome label.
            
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            //儲存用戶名稱
            //            [userDefaults setValue:[user objectForKey:kPAPUserDisplayNameKey] forKey:kCMUserNameString];
            [userDefaults setValue:privateChannelName forKey:kPAPUserPrivateChannelKey];
            [userDefaults synchronize];
            //            [[PFUser currentUser] setObject:[user objectForKey:kPAPUserDisplayNameKey] forKey:kPAPUserDisplayNameKey];
            [[PFUser currentUser] setObject:privateChannelName forKey:kPAPUserPrivateChannelKey];
            
            PFACL *ACL = [PFACL ACL];
            [ACL setPublicReadAccess:YES];
            [PFUser currentUser].ACL = ACL;
            
            [[PFUser currentUser] saveEventually];
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    [self facebookRequestDidLoad:result];
                    //轉場到 註冊2 的畫面
                    NSLog(@"loginToSet");
                    [logInController performSegueWithIdentifier:@"loginToSet" sender:nil];
                } else {
                    [self facebookRequestDidFailWithError:error];
                }
            }];
            
            
        } else {
            // If user is linked to neither, let's use their username for the Welcome label.
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            //儲存用戶名稱
            [userDefaults setValue:user.username forKey:kCMUserNameString];
            [userDefaults setValue:privateChannelName forKey:kPAPUserPrivateChannelKey];
            [userDefaults synchronize];
            [[PFUser currentUser] setObject:user.username forKey:kPAPUserDisplayNameKey];
            [[PFUser currentUser] setObject:privateChannelName forKey:kPAPUserPrivateChannelKey];
            
            PFACL *ACL = [PFACL ACL];
            [ACL setPublicReadAccess:YES];
            [PFUser currentUser].ACL = ACL;
            
            [[PFUser currentUser] saveEventually];
            
            //轉場到 註冊2 的畫面
            NSLog(@"loginToSet");
            [logInController performSegueWithIdentifier:@"loginToSet" sender:nil];
        }
    }else{
        //轉場至 google Map 畫面
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentGoogleMapController];
    }
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"invalid login credentials!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - Facebook Request Delegate
- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[CMCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                
                // find common Facebook friends already using Anypic
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow Parse employees
                //                PFQuery *autoFollowAccountsQuery = [PFUser query];
                //                [autoFollowAccountsQuery whereKey:kPAPUserFacebookIDKey containedIn:kPAPAutoFollowAccountFacebookIds];
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:facebookFriendsQuery, nil]];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    NSArray *anypicFriends = objects;
                    
                    if (!error) {
                        [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                            PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                            [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                            [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                            [joinActivity setObject:[NSNumber numberWithInt:kPAPActivityTypeJoined] forKey:kPAPActivityTypeKey];
                            
                            PFACL *joinACL = [PFACL ACL];
                            [joinACL setPublicReadAccess:YES];
                            joinActivity.ACL = joinACL;
                            
                            // make sure our join activity is always earlier than a follow
                            [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [CMUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                    // This block will be executed once for each friend that is followed.
                                    // We need to refresh the timeline when we are following at least a few friends
                                    // Use a timer to avoid refreshing innecessarily
                                    if (self.autoFollowTimer) {
                                        [self.autoFollowTimer invalidate];
                                    }
                                    
                                    self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                                }];
                            }];
                        }];
                    }
                    
                    if (!error) {
                        [MBProgressHUD hideHUDForView:self.view animated:NO];
                        if (anypicFriends.count > 0) {
                            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                            self.hud.dimBackground = YES;
                            self.hud.labelText = NSLocalizedString(@"Following Friends", nil);
                        } else {
                            
                        }
                    }
                }];
            }
            PFACL *ACL = [PFACL ACL];
            [ACL setPublicReadAccess:YES];
            user.ACL = ACL;
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"Creating Profile", nil);
        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
        //新增用戶資料 名字、姓氏、性別、地區(用Graph API的代號)
        NSString *facebookFirst_Name = [result objectForKey:@"first_name"];
        NSString *facebookLast_Name = [result objectForKey:@"last_name"];
        NSString *facebookBirthday = [result objectForKey:@"birthday"];
        NSString *facebookEmail = [result objectForKey:@"email"];
        NSString *facebookGender = [result objectForKey:@"gender"];
        NSString *facebookLocation = [result objectForKey:@"locale"];
        
        if (user) {
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"某人" forKey:kPAPUserDisplayNameKey];
            }
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            //儲存姓氏
            if (facebookFirst_Name && facebookFirst_Name != 0) {
                [[PFUser currentUser] setObject:facebookFirst_Name forKey:kPAPUserFacebookFirstNameKey];
            }
            //儲存名字
            if (facebookLast_Name && facebookLast_Name != 0) {
                [[PFUser currentUser] setObject:facebookLast_Name forKey:kPAPUserFacebookLastNameKey];
            }
            //儲存生日
            if (facebookBirthday && facebookBirthday != 0) {
                [[PFUser currentUser] setObject:facebookBirthday forKey:kPAPUserFacebookBirthdayKey];
            }
            //儲存email
            if (facebookEmail && facebookEmail != 0) {
                [[PFUser currentUser] setObject:facebookEmail forKey:kPAPUserFacebookEmailKey];
            }
            //儲存性別
            if (facebookGender && facebookGender != 0) {
                [[PFUser currentUser] setObject:facebookGender forKey:kPAPUserFacebookGenderKey];
            }
            //儲存地理位置
            if (facebookLocation && facebookLocation != 0) {
                [[PFUser currentUser] setObject:facebookLocation forKey:kPAPUserFacebookLocalsKey];
            }
            //設定新用戶預設為乘車客人
            [[PFUser currentUser] setObject:kPAPUserTypePassengerKey forKey:kPAPUserTypeKey];
            
            //設定新用戶接收頻率為10, 等級為1~10
            //            [[PFUser currentUser] setObject:[NSNumber numberWithInt:10] forKey:kPAPUserFrequencyKey];
            
            NSLog(@"正在下載用戶檔案照片...delegate");
            // Download user's profile picture
            NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectForKey:kPAPUserFacebookIDKey]]];
            // Facebook profile picture cache policy: Expires in 2 weeks
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.0f];
            [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
            
            PFACL *ACL = [PFACL ACL];
            [ACL setPublicReadAccess:YES];
            [PFUser currentUser].ACL = ACL;
            
            [[PFUser currentUser] saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        }
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //    UIImage *smallRoundedImage = [[UIImage imageWithData:_data] thumbnailImage:64 transparentBorder:0 cornerRadius:32 interpolationQuality:kCGInterpolationLow];
    [CMUtility processFacebookProfilePictureData:_data];
}

#pragma mark - 自動Follow Facebook 朋友
- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
