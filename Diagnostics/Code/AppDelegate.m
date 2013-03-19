//
//  AppDelegate.m
//  Diagnostics
//
//  Created by Alexander Schuch on 12/03/13.
//  Copyright (c) 2013 Pusher. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+PusherDiagnostics.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self _setupAppearance];
    [self _setupUserDefaults];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/////////////////////////////////
#pragma mark - UserDefaults
/////////////////////////////////

- (void)_setupUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:kUserDefaultsSSLEnabled]) {
        [defaults setBool:NO forKey:kUserDefaultsSSLEnabled];
    }
    
    if (![defaults objectForKey:kUserDefaultsReconnectEnabled]) {
        [defaults setBool:YES forKey:kUserDefaultsReconnectEnabled];
    }
    
    [defaults synchronize];
}


/////////////////////////////////
#pragma mark - UIAppearance
/////////////////////////////////

- (void)_setupAppearance
{
    UIImage *navigationBarBackground = [UIImage imageNamed:@"navigationbar_background.png"];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBackground forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor grayColor],
                          UITextAttributeTextShadowColor: [UIColor pusherDiagnosticsLightGrey]}];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor pusherDiagnosticsLightGrey]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor darkGrayColor],
                          UITextAttributeTextShadowColor: [UIColor clearColor]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor grayColor],
                          UITextAttributeTextShadowColor: [UIColor clearColor]} forState:UIControlStateSelected];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor grayColor],
                          UITextAttributeTextShadowColor: [UIColor clearColor]} forState:UIControlStateHighlighted];
}

@end
