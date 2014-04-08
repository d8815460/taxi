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
#import "JSONKit.h"

@interface GoogleMapViewController (){
    GMSMarker *_stopMarker;
}

@end

@implementation GoogleMapViewController{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    BOOL isReadLocation_;
}
@synthesize driverBtn, passengersBtn, uploadOrStopLocation;
@synthesize titleLabel;

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
    
    CGRect frame = CGRectMake(0, 0, 240, 44);
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = @"乘車地點";
    self.navigationItem.titleView = self.titleLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 初始化 iOSLocation
    iOSLocation = [[CLLocationManager alloc] init];
    iOSLocation.delegate = self;
    //開始計算目前行動裝置所在位置的功能。比較精准耗電。乘客用。
    [iOSLocation startUpdatingLocation];
    
    /* 司機身份調用的方法。調用該方法設備一定要有電話模組。
    [iOSLocation startMonitoringSignificantLocationChanges];
    */
    
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (iOSLocation.location.coordinate.latitude && iOSLocation.location.coordinate.longitude) {
//        NSLog(@"精度%f, 緯度%f", iOSLocation.location.coordinate.latitude, iOSLocation.location.coordinate.longitude);
        
        // Do any additional setup after loading the view.
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:iOSLocation.location.coordinate.latitude
                                                                longitude:iOSLocation.location.coordinate.longitude
                                                                     zoom:15];
        
        mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        mapView_.delegate = self;
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
        
        // custom Marker
        _stopMarker = [[GMSMarker alloc] init];
        _stopMarker.title = @"設定上車地點";
        _stopMarker.position = iOSLocation.location.coordinate;
        _stopMarker.appearAnimation = kGMSMarkerAnimationPop;
        _stopMarker.flat = NO;
        _stopMarker.draggable = YES;
        _stopMarker.groundAnchor = CGPointMake(0.5, 0.5);
        _stopMarker.map = mapView_;
        
        
        
        mapView_.selectedMarker = _stopMarker;
        
        //更新地址
        [self uploadAddress:iOSLocation.location.coordinate];
    }else{
        //一秒後啟動doAfterOneSecond
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(viewDidAppear:) userInfo:nil repeats:NO];
    }
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


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // If it's a relatively recent event, turn off updates to save power
    // 如果它是一個相對較新的事件，關閉更新，以節省電力
    CLLocation *location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        // 如果該事件是最新的，用它做什麼。
        NSLog(@"緯度:%f, 經度:%f, 高度:%f", location.coordinate.latitude, location.coordinate.longitude, location.altitude);
        
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLocation:location];
        
        if (currentPoint.latitude != 0.0 && currentPoint.longitude != 0.0) {
            PFObject *currentLocation = [PFObject objectWithClassName:kPAPUserLocationClassKey];
            [currentLocation setObject:[PFUser currentUser] forKey:kPAPUserLocationUserKey];
            [currentLocation setObject:currentPoint forKey:kPAPUserLocationLocationKey];
            
            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [ACL setPublicReadAccess:YES];
            currentLocation.ACL = ACL;
            
            [currentLocation saveEventually:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"記錄用戶經緯度");
                }
            }];
            
            [[PFUser currentUser] setObject:currentPoint forKey:kPAPUserLocationLocationKey];
            [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"用戶最新位置已經上傳");
                }
            }];
        }
    }
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
//    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
//    NSLog(@"keyPath = %@, Object = %@, context = %@", keyPath, object, context);
    
//    mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
    
    //更新地址
//    [self uploadAddress:location.coordinate];
    
//    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLocation:location];
//    PFObject *currentLocation = [PFObject objectWithClassName:kPAPUserLocationClassKey];
//    [currentLocation setObject:[PFUser currentUser] forKey:kPAPUserLocationUserKey];
//    [currentLocation setObject:currentPoint forKey:kPAPUserLocationLocationKey];
//    
//    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
//    [ACL setPublicReadAccess:YES];
//    currentLocation.ACL = ACL;
//    
//    [currentLocation saveEventually:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"儲存經緯度");
//        }
//    }];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    _stopMarker.position = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    _stopMarker.position = CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude);
    //開始更新地址
    [self uploadAddress:_stopMarker.position];
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture{
//    NSLog(@"%i", gesture);
}

//- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
////    mapView_.selectedMarker = marker;
//    return YES;
//}

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
    if (isReadLocation_) {
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

- (void)uploadAddress:(CLLocationCoordinate2D)coor {
    /*
     分析google地理位置
     */
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%f,%f&sensor=true",coor.latitude, coor.longitude];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *jsonStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *resultDict = [jsonStr objectFromJSONString];
    if ([[resultDict objectForKey:@"status"] isEqualToString:@"OK"]) {
        NSDictionary *dict = [[resultDict objectForKey:@"results"] objectAtIndex:0];
        NSString *formatted_address = [dict objectForKey:@"formatted_address"];
        
        self.titleLabel.text = formatted_address;
    }
}
@end
