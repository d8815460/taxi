//
//  SetProfileViewController.m
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import "SetProfileViewController.h"

#define firstNameTag 100
#define lastNameTag  101

@interface SetProfileViewController ()

@end

@implementation SetProfileViewController
@synthesize userPhotoImageView;
@synthesize nextBtn, firstNameTextField, lastNameTextField;

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
    self.nextBtn.title = @"";
    [self.nextBtn setEnabled:NO];
    self.firstNameTextField.delegate = self;
    self.firstNameTextField.tag = firstNameTag;
    self.lastNameTextField.delegate = self;
    self.lastNameTextField.tag = lastNameTag;
}

- (void)viewDidAppear:(BOOL)animated{
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        self.userPhotoImageView.image = [UIImage imageWithData:oldProfilePictureData];
    }
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

- (IBAction)nextBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"connectCreditCard" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"connectCreditCard"]) {
        
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag == firstNameTag) {
        if (range.length == 0) {
            if (self.firstNameTextField.text.length + 1 > 0 && self.lastNameTextField.text.length > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }else{
            if (self.firstNameTextField.text.length - 1 > 0 && self.lastNameTextField.text.length > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }
    }else if (textField.tag == lastNameTag){
        if (range.length == 0) {
            if (self.firstNameTextField.text.length  > 0 && self.lastNameTextField.text.length + 1 > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }else{
            if (self.firstNameTextField.text.length > 0 && self.lastNameTextField.text.length - 1 > 0) {
                self.nextBtn.title = @"Next";
                [self.nextBtn setEnabled:YES];
            }else{
                self.nextBtn.title = @"";
                [self.nextBtn setEnabled:NO];
            }
        }
    }
    return YES;
}
@end
