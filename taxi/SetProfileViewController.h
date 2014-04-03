//
//  SetProfileViewController.h
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetProfileViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBtn;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;



- (IBAction)nextBtnPressed:(id)sender;

@end
