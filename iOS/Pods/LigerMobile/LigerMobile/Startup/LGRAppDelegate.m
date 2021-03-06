//
//  LGRAppDelegate.m
//  LigerMobile
//
//  Created by John Gustafsson on 1/11/13.
//  Copyright (c) 2013-2014 ReachLocal Inc. All rights reserved.  https://github.com/reachlocal/liger-ios/blob/master/LICENSE
//

#import "LGRAppDelegate.h"
#import "LGRApp.h"
#import "LGRAppearance.h"
#import "LGRPageFactory.h"
#import "LGRViewController.h"

@interface LGRAppDelegate()
@property(assign) BOOL wasStartedByNotification;
@end

@implementation LGRAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	[LGRApp setupPushNotifications];
	[LGRAppearance setupApperance];

	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitStoreWebDataForBackup"];

	NSDictionary *remoteNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
	NSMutableDictionary *args = [LGRApp.root[@"args"] mutableCopy] ?: [NSMutableDictionary dictionary];
	if (remoteNotification) {
		args[@"notification"] = remoteNotification;
		self.wasStartedByNotification = YES;
	}

	UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
	if (localNotification) {
		args[@"notification"] = localNotification.userInfo;
		self.wasStartedByNotification = YES;
	}

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = UIColor.whiteColor;
	self.window.rootViewController = [LGRPageFactory controllerForPage:LGRApp.root[@"page"] title:LGRApp.root[@"title"] args:args options:LGRApp.root[@"options"] parent:nil];

	NSAssert(self.window.rootViewController, @"Root page '%@' not found.", LGRApp.root[@"page"]);
	[self.window makeKeyAndVisible];

	return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSUInteger length = [deviceToken length];

	int32_t a[length/4 + !!(length%4)];
	[deviceToken getBytes:a length:length];

	NSString *token = @"";
	for (NSUInteger i=0; i < length/4 + !!(length%4); i++) {
		UInt8 *bytes = (UInt8*)&a[i];
		token = [token stringByAppendingFormat:@"%02x%02x%02x%02x", bytes[0], bytes[1], bytes[2], bytes[3]];
	}

	[[self rootPage] pushNotificationTokenUpdated:token error:nil];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	[[self rootPage] pushNotificationTokenUpdated:nil error:error];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	UIApplicationState state = [application applicationState];
	[self notificationArrived:notification.userInfo state:state];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	UIApplicationState state = [application applicationState];
	[self notificationArrived:userInfo state:state];
}

- (void)notificationArrived:(NSDictionary*)userInfo state:(UIApplicationState)state
{
	if (self.wasStartedByNotification) {
		self.wasStartedByNotification = NO;
		return;
	}

	[[self rootPage] notificationArrived:userInfo state:state];
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
	[[self rootPage] handleAppOpenURL:url];
	return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[self.topPage pageWillAppear];
}

- (LGRViewController*)rootPage
{
	NSAssert([self.window.rootViewController isKindOfClass:LGRViewController.class], @"self.window.rootViewController must be a LGRViewController.");
	return (LGRViewController*)self.window.rootViewController;
}

@end
