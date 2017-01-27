//
//  AppDelegate.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

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
    NSLog(@"username: %@ password: %@", username, password);
    if(username && password){
        [self.paths import];
    }
    if (token) {
        NSLog(@"importing paths");
        [self.paths import];
    }
    
    

    // Override point for customization after application launch.
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

-(void)activateUser{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook"];
    
    if(username && password){
        id block = ^{
            NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/login"];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
            request.HTTPMethod = @"POST";
            NSDictionary *dict = @{
                                   @"username" : username,
                                   @"password" : password,
                                   };
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            request.HTTPBody = jsonData;
            [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
                //Completion block
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) res;
                        NSLog(@"response status code: %lu", (long)[httpResponse statusCode]);
                        if ([httpResponse statusCode] == 200) {
                            //User has been verified
                            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                            self.activeUser = [[User alloc] initWithDictionary:dict];
                            
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                            //[self dismissViewControllerAnimated:YES completion:nil];
                        } else {
                            NSLog(@"%ld", (long)[httpResponse statusCode]);
                            //user has not been verified
                        };
                    } else {
                        NSLog(@"Something went wrong: %@", [error localizedDescription]);
                    }
                });
            }];
            [dataTask resume];
        };
        //Create a Grand Central Dispatch queue and run the operation async
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, block);
    }
    if (token){
        id block = ^{
            //NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
            //NSLog(@"This is token: %@", fbAccessToken);
            NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/auth/facebook/token"];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
            request.HTTPMethod = @"POST";
            NSError* error = nil;
            NSDictionary *dict = @{
                                   @"access_token" : token
                                   };
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                               options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                 error:&error];
            request.HTTPBody = jsonData;
            [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                //Completion block
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error == nil) {
                        NSLog(@"res: %@", response);
                        if (response.expectedContentLength < 5){
                            //User exists in database
                            NSLog(@"token still valid");
                        }
                    }
                    else {
                        NSLog(@"error: %@", error.localizedDescription);
                    }
                });
            }];
            [dataTask resume];
        };
        //Create a Grand Central Dispatch queue and run the operation async
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, block);
    }
}

@end
