//
//  AppDelegate.h
//  taxi
//
//  Created by Ayi on 2014/4/1.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapViewController.h"
#import <Reachability.h>                    //判斷網路是否可用

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GoogleMapViewController *mainMap;
@property (nonatomic, strong) Reachability *hostReach;                                  //判斷網路是否可用
@property (nonatomic, strong) Reachability *internetReach;                              //判斷網路是否可用
@property (nonatomic, strong) Reachability *wifiReach;                                  //判斷wifi網路是否可用
@property (nonatomic, readonly) int networkStatus;


@end
