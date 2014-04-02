//
//  AyiWellcomeViewController.h
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AyiLoginViewController.h"
#import "AyiSignUpViewController.h"

@interface AyiWellcomeViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic, strong) AyiLoginViewController *loginViewController;
@property (nonatomic, strong) AyiSignUpViewController *signupViewController;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)signupButtonPressed:(id)sender;
@end
