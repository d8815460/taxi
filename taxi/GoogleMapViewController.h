//
//  GoogleMapViewController.h
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GoogleMapViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate>{
    CLLocationManager *iOSLocation; //專門負責用來開關行動裝置的坐標接收
}

@property (weak, nonatomic) IBOutlet UIButton *uploadOrStopLocation;
@property (weak, nonatomic) IBOutlet UIButton *passengersBtn;
@property (weak, nonatomic) IBOutlet UIButton *driverBtn;
@property (strong, nonatomic) UILabel  *titleLabel;


- (IBAction)driverBtnPressed:(id)sender;
- (IBAction)passengersBtn:(id)sender;
- (IBAction)uploadOrStopLocationBtnPressed:(id)sender;

- (void)uploadAddress:(CLLocationCoordinate2D)coor;

@end
