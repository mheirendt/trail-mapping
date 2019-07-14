//
//  AppDelegate.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self activateUser];
    _trails = [[NSMutableArray alloc] init];
    _categories = [[NSMutableArray alloc] init];
    self.paths = [[Paths alloc] init];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook"];
    if((username && password) || token){
        [self.paths import];
    }
    return YES;
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self activateUser];
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)updateActiveUser {
    id block = ^{
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/profile"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"GET";
        [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
            //Completion block
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                self.activeUser = [[User alloc] initWithDictionary:dict];
            });
            
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

-(void)activateUser{
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook"];
    NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];

    if(username && password)
    {
        NSDictionary *dict = @{
                               @"username" : username,
                               @"password" : password,
                               };
        [[[User alloc] init] login:dict completionBlock:^(NSData * data)
        {
            if (data != nil)
            {
                //User has been verified
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                self.activeUser = [[User alloc] initWithDictionary:dict];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebook"];
                [[NSUserDefaults standardUserDefaults] setObject:@"signin" forKey:@"signin"];
            }
        }];
    }
    if (token)
    {
        [[[User alloc] init] loginWithFacebook:^(NSData * data){
            if (data != nil)
            {
                //User has been verified
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                self.activeUser = [[User alloc] initWithDictionary:dict];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebook"];
                [[NSUserDefaults standardUserDefaults] setObject:@"signin" forKey:@"signin"];
            }
        }];
    }
}

@end
