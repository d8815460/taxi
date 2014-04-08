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
#import "AppDelegate.h"
#import "PAWSearchRadius.h"

@interface GoogleMapViewController (){
    GMSMarker *_stopMarker;
}
@property (nonatomic, strong) PAWSearchRadius *searchRadius;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;
// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (void)updatePostsForLocation:(CLLocation *)location withNearbyDistance:(CLLocationAccuracy) filterDistance;

@end

@implementation GoogleMapViewController{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    BOOL isReadLocation_;
    BOOL isDriver;
}
@synthesize driverBtn, passengersBtn, uploadOrStopLocation;
@synthesize titleLabel;
@synthesize searchRadius = _searchRadius;
@synthesize mapPannedSinceLocationUpdate = _mapPannedSinceLocationUpdate;               //地圖平移由於位置更新，地圖會跟著用戶跑？

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];
    
    // 初始化 iOSLocation
    iOSLocation = [[CLLocationManager alloc] init];
    iOSLocation.delegate = self;
    
    
    //開始計算目前行動裝置所在位置的功能。比較精准耗電。乘客用。
    [iOSLocation startUpdatingLocation];
    
    /* 司機身份調用的方法。調用該方法設備一定要有電話模組。
    [iOSLocation startMonitoringSignificantLocationChanges];
    */
    
    if ([[[PFUser currentUser] objectForKey:kPAPUserTypeKey] isEqualToString:kPAPUserTypeDriverKey]) {
        isDriver = YES;
        [self driverBtnPressed:nil];
    }else if ([[[PFUser currentUser] objectForKey:kPAPUserTypeKey] isEqualToString:kPAPUserTypePassengerKey]){
        isDriver = NO;
        [self passengersBtn:nil];
    }
    
    //一開始，地圖不會跟著用戶跑。
    self.mapPannedSinceLocationUpdate = NO;
    
    isReadLocation_ = YES;
    isDriver = NO;
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
    
    [iOSLocation stopUpdatingLocation];
    [iOSLocation stopMonitoringSignificantLocationChanges];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
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

#pragma mark - NSNotificationCenter notification handlers
- (void)distanceFilterDidChange:(NSNotification *)note {
	CLLocationAccuracy filterDistance = [[[note userInfo] objectForKey:kPAWFilterDistanceKey] doubleValue];
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
	if (self.searchRadius == nil) {
		self.searchRadius = [[PAWSearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
        
//		[self.mapView addOverlay:self.searchRadius];
	} else {
		self.searchRadius.radius = appDelegate.filterDistance;
	}
    
	// Update our pins for the new filter distance:
	[self updatePostsForLocation:appDelegate.currentLocation withNearbyDistance:filterDistance];
    
    //地圖是否跟著用戶跑
    //If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their location at 2x filterDistance
//		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//        
//		[self.mapView setRegion:newRegion animated:YES];
//		self.mapPannedSinceLocationUpdate = NO;
	} else {
		// Just zoom to the new search radius (or maybe don't even do that?)
//		MKCoordinateRegion currentRegion = mapView.region;
//		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//        
//		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
//		[self.mapView setRegion:newRegion animated:YES];
//		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
	}
}

- (void)locationDidChange:(NSNotification *)note {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	// If they panned the map since our last location update, don't recenter it.
	if (!self.mapPannedSinceLocationUpdate) {
		// Set the map's region centered on their new location at 2x filterDistance
//		MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//        
//		BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
//		[self.mapView setRegion:newRegion animated:YES];
//		self.mapPannedSinceLocationUpdate = oldMapPannedValue;
        
        //        double lat = appDelegate.currentLocation.coordinate.latitude;
        //        double lon = appDelegate.currentLocation.coordinate.longitude;
        //        PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:lat longitude:lon];
        
        //        PFObject *UserLocation = [PFObject objectWithClassName:@"UserLocation"];
        //        [UserLocation setObject:[PFUser currentUser] forKey:@"user"];
        //        [UserLocation setObject:location forKey:@"location"];
        
        //        [UserLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //            //Coding here
        //        }];
        
	} // else do nothing.
    
	// If we haven't drawn the search radius on the map, initialize it.
	if (self.searchRadius == nil) {
		self.searchRadius = [[PAWSearchRadius alloc] initWithCoordinate:appDelegate.currentLocation.coordinate radius:appDelegate.filterDistance];
//		[self.mapView addOverlay:self.searchRadius];
	} else {
		self.searchRadius.coordinate = appDelegate.currentLocation.coordinate;
	}
    
	// Update the map with new pins:
	[self queryForAllPostsNearLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
	// And update the existing pins to reflect any changes in filter distance:
	[self updatePostsForLocation:appDelegate.currentLocation withNearbyDistance:appDelegate.filterDistance];
}



#pragma mark - Fetch map pins
//搜尋當前乘車用戶附近所有的其他司機用戶。
- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    
//    [self startSignificantChangeUpdates];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set the map's region centered on their new location at 2x filterDistance
//    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 120.0f)];
//    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, appDelegate.filterDistance / 2, appDelegate.filterDistance / 2);
//    [self.mapView setRegion:newRegion animated:YES];
//	self.mapPannedSinceLocationUpdate = NO;
//    self.mapView.zoomEnabled = NO;              //允許縮放地圖與否
//    self.mapView.scrollEnabled = NO;            //允許拖曳捲動地圖與否。
//    self.mapView.delegate = self;
//    self.mapView.showsUserLocation = YES;            //用戶當前位置顯示
    
    //    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, nearbyDistance / 2, nearbyDistance / 2);
    //    [self.mapView setRegion:newRegion animated:YES];
    
    
	PFQuery *query = [PFUser query];
    
	if (currentLocation == nil) {
		NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
	}
    
	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.allPosts count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
	// Query for posts sort of kind of near our current location.
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
	[query whereKey:kPAPUserLocationLocationKey nearGeoPoint:point withinKilometers:kPAWWallPostMaximumSearchDistance];
//	[query includeKey:kPAPPhotoUserKey];
	query.limit = kPAWMapCarsSearch;
    
    //搜尋24小時以內的資料
    NSDate *twoWeeksBeforeNow = [NSDate dateWithTimeIntervalSinceReferenceDate:([NSDate timeIntervalSinceReferenceDate] - 24*60*60 * 1)];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:twoWeeksBeforeNow];
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"error in geo query!"); // todo why is this ever happening?
		} else {
			// We need to make new post objects from objects,
			// and update allPosts and the map to reflect this new array.
			// But we don't want to remove all annotations from the mapview blindly,
			// so let's do some work to figure out what's new and what needs removing.
            
			// 1. Find genuinely new posts:
			NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:kPAWWallPostsSearch];
			// (Cache the objects we make for the search in step 2:)
			NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:kPAWWallPostsSearch];
			for (PFObject *object in objects) {
				PAWPost *newPost = [[PAWPost alloc] initWithPFObject:object];
				[allNewPosts addObject:newPost];
				BOOL found = NO;
				for (PAWPost *currentPost in allPosts) {
					if ([newPost equalToPost:currentPost]) {
						found = YES;
					}
				}
				if (!found) {
					[newPosts addObject:newPost];
				}
			}
			// newPosts now contains our new objects.
            
			// 2. Find posts in allPosts that didn't make the cut.
			NSMutableArray *postsToRemove = [[NSMutableArray alloc] initWithCapacity:kPAWWallPostsSearch];
			for (PAWPost *currentPost in allPosts) {
				BOOL found = NO;
				// Use our object cache from the first loop to save some work.
				for (PAWPost *allNewPost in allNewPosts) {
					if ([currentPost equalToPost:allNewPost]) {
						found = YES;
					}
				}
				if (!found) {
					[postsToRemove addObject:currentPost];
				}
			}
			// postsToRemove has objects that didn't come in with our new results.
            
			// 3. Configure our new posts; these are about to go onto the map.
			for (PAWPost *newPost in newPosts) {
				CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newPost.coordinate.latitude longitude:newPost.coordinate.longitude];
				// if this post is outside the filter distance, don't show the regular callout.
				CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
				[newPost setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
				// Animate all pins after the initial load:
				newPost.animatesDrop = mapPinsPlaced;
			}
            
            
            
			// At this point, newAllPosts contains a new list of post objects.
			// We should add everything in newPosts to the map, remove everything in postsToRemove,
			// and add newPosts to allPosts.
			[self.mapView removeAnnotations:postsToRemove];
			[self.mapView addAnnotations:newPosts];
            //            NSLog(@"newPosts = %@", newPosts);
			[allPosts addObjectsFromArray:newPosts];
			[allPosts removeObjectsInArray:postsToRemove];
            
            // This method is called every time objects are loaded from Parse via the PFQuery
            // This method is called before a PFQuery is fired to get more objects
            lastRefresh = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            
			self.mapPinsPlaced = YES;
		}
	}];
}

// When we update the search filter distance, we need to update our pins' titles to match.
- (void)updatePostsForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
    // 更新地圖上的車輛。
    
//	for (PAWPost *post in allPosts) {
//		CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:post.coordinate.latitude longitude:post.coordinate.longitude];
//		// if this post is outside the filter distance, don't show the regular callout.
//		CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
//		if (distanceFromCurrent > nearbyDistance) { // Outside search radius
//			[post setTitleAndSubtitleOutsideDistance:YES];
//			[mapView viewForAnnotation:post];
//			[(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
//		} else {
//			[post setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
//			[mapView viewForAnnotation:post];
//			[(MKPinAnnotationView *) [mapView viewForAnnotation:post] setPinColor:post.pinColor];
//		}
//	}
}

#pragma mark - CLLocationManagerDelegate methods and helpers
- (void)startSignificantChangeUpdates {
	if (nil == iOSLocation) {
		iOSLocation = [[CLLocationManager alloc] init];
	}
    
	iOSLocation.delegate = self;
    [iOSLocation startMonitoringSignificantLocationChanges];
    
	iOSLocation.desiredAccuracy = kCLLocationAccuracyBest;
    
	// Set a movement threshold for new events.
	iOSLocation.distanceFilter = kCLLocationAccuracyNearestTenMeters;
	[iOSLocation startUpdatingLocation];
    
    
    
	CLLocation *currentLocation = iOSLocation.location;
	if (currentLocation) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.currentLocation = currentLocation;
        
        
        //儲存當前用戶位置
        PFGeoPoint *location = [PFGeoPoint geoPointWithLatitude:appDelegate.currentLocation.coordinate.latitude longitude:appDelegate.currentLocation.coordinate.longitude];
        //儲存用戶所在地經緯度
        PFUser *currentUserData = [PFUser currentUser];
        if (location.latitude && location.longitude ) {
            [currentUserData setObject:location forKey:@"location"];
        }
        //儲存用戶資料
        [currentUserData saveEventually];
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			// Re-enable the post button if it was disabled before.
			[iOSLocation startUpdatingLocation];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
        {{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Taxi 無法訪問當前位置。\n\n同意Taxi訪問您當前位子。" message:nil delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alertView show];
        }}
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Code.....
    switch (buttonIndex) {
        case 0:
            NSLog(@"確定取消");
            break;
        case 1:
            NSLog(@"確定開啓");
            NSURL *prefsURL = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
            
            if ([[UIApplication sharedApplication] canOpenURL:prefsURL]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
            } else {
                // Can't redirect user to settings, display alert view
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
                NSLog(@"無法開啓喔");
            }
            break;
    }
}

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
        
        if (currentPoint.latitude && currentPoint.longitude) {
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


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"Error: %@", [error description]);
    
	if (error.code == kCLErrorDenied) {
		[iOSLocation stopUpdatingLocation];
        [iOSLocation stopMonitoringSignificantLocationChanges];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:@"請重新設定同意啟用位置服務"
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
	} else if (error.code == kCLErrorLocationUnknown) {
		// todo: retry?
		// set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
        
	} else if (error.code == kCLErrorLocationUnknown){
        
    }else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
		                                                message:@"檢索位置發生錯誤"
		                                               delegate:nil
		                                      cancelButtonTitle:nil
		                                      otherButtonTitles:@"Ok", nil];
		[alert show];
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
    _stopMarker.map = nil;
    isDriver = YES;
    [iOSLocation startMonitoringSignificantLocationChanges];
    [iOSLocation stopUpdatingLocation];
}

- (IBAction)passengersBtn:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:kPAPUserTypePassengerKey forKey:kPAPUserTypeKey];
    
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    currentUser.ACL = ACL;
    
    [currentUser saveEventually:^(BOOL succeeded, NSError *error) {
        
    }];
    _stopMarker.map = (GMSMapView *)self.view;
    mapView_.selectedMarker = _stopMarker;
    isDriver = NO;
    [iOSLocation startUpdatingLocation];
    [iOSLocation stopMonitoringSignificantLocationChanges];
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
