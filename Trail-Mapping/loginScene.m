//
//  loginScene.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/9/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "loginScene.h"
#import "AppDelegate.h"

@interface loginScene ()

@end

@implementation loginScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissTheKeyboard{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
- (IBAction)userSignIn:(id)sender {
}
- (IBAction)backPressed:(id)sender {
[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
}

-(IBAction)validateUser:(id)sender{
    id block = ^{
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/login"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        NSDictionary *dict = @{
                           @"username" : _usernameField.text,
                           @"password" : _passwordField.text,
                           };
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        request.HTTPBody = jsonData;
        [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *   error) {
            //Completion block
            if (error == nil) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) res;
                NSLog(@"response status code: %lu", (long)[httpResponse statusCode]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([httpResponse statusCode] == 200) {
                        //User has been verified
                        [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
                        [[NSUserDefaults standardUserDefaults] setValue:_passwordField.text forKey:@"password"];
                
                        AppDelegate *del;
                        del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [del.paths import];
                
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                        //[self dismissViewControllerAnimated:YES completion:nil];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        NSLog(@"%ld", (long)[httpResponse statusCode]);
                        //user has not been verified
                    };
                });
            } else {
                NSLog(@"Something went wrong: %@", [error localizedDescription]);
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}


#pragma mark - Hide and show the tab bar
// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}
@end
