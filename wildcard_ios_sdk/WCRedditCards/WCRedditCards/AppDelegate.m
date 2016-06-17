//
//  AppDelegate.m
//  WCRedditCards
//
//  Created by David Xiang on 3/18/15.
//  Copyright (c) 2015 com.trywildcard. All rights reserved.
//

#import "AppDelegate.h"
@import WildcardSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"Using WildcardSDK version: %f", WildcardSDKVersionNumber);
    
    // initialize
    [WildcardSDK initializeWithApiKey:@"4f154853-1955-4422-9aa3-f1fbd89d3403"];
    
    return YES;
}



@end
