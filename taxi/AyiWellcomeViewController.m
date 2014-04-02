//
//  AyiWellcomeViewController.m
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import "AyiWellcomeViewController.h"

@interface AyiWellcomeViewController ()

@end

@implementation AyiWellcomeViewController
@synthesize loginViewController = _loginViewController;
@synthesize signupViewController = _signupViewController;

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

@end
