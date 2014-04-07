//
//  GoogleMapViewController.h
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *uploadOrStopLocation;
@property (weak, nonatomic) IBOutlet UIButton *passengersBtn;
@property (weak, nonatomic) IBOutlet UIButton *driverBtn;


- (IBAction)driverBtnPressed:(id)sender;
- (IBAction)passengersBtn:(id)sender;
- (IBAction)uploadOrStopLocationBtnPressed:(id)sender;
@end
