//
//  GoogleMapViewController.m
//  taxi
//
//  Created by Ayi on 2014/4/2.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//
#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "GoogleMapViewController.h"

@interface GoogleMapViewController ()

@end

@implementation GoogleMapViewController{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    BOOL isReadLocation_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isReadLocation_ = YES;
    [self.uploadOrStopLocation setTitle:@"關閉更新位置" forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [mapView_ addSubview:self.driverBtn];
    [mapView_ addSubview:self.passengersBtn];
    [mapView_ addSubview:self.uploadOrStopLocation];
    
    self.view = mapView_;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    
    
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@YES forKey:kPAPUserIsReadLocationKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
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
#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
//    NSLog(@"keyPath = %@, Object = %@, context = %@", keyPath, object, context);
    
    mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:14];
    
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLocation:location];
    PFObject *currentLocation = [PFObject objectWithClassName:kPAPUserLocationClassKey];
    [currentLocation setObject:[PFUser currentUser] forKey:kPAPUserLocationUserKey];
    [currentLocation setObject:currentPoint forKey:kPAPUserLocationLocationKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentLocation.ACL = ACL;
    
    [currentLocation saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"儲存經緯度");
        }
    }];
}

#pragma mark - Actions
- (IBAction)driverBtnPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:kPAPUserTypeDriverKey forKey:kPAPUserTypeKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
}

- (IBAction)passengersBtn:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:kPAPUserTypeDriverKey forKey:kPAPUserTypeKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
}

- (IBAction)uploadOrStopLocationBtnPressed:(id)sender {
    NSLog(@"BOOL = %@\n", (isReadLocation_ ? @"YES" : @"NO"));
    if (isReadLocation_) {
        NSLog(@"1");
        isReadLocation_ = NO;
        [self.uploadOrStopLocation setTitle:@"啟動更新位置" forState:UIControlStateNormal];
        
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setObject:@NO forKey:kPAPUserIsReadLocationKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        currentUser.ACL = ACL;
        
        [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
            
        }];
    }else{
        NSLog(@"2");
        isReadLocation_ = YES;
        [self.uploadOrStopLocation setTitle:@"關閉更新位置" forState:UIControlStateNormal];
        
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setObject:@YES forKey:kPAPUserIsReadLocationKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        currentUser.ACL = ACL;
        
        [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
            
        }];
    }
    
}


@end
