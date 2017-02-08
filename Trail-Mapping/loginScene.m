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
    FBSDKLoginButton *fbButton = [[FBSDKLoginButton alloc] init];
    fbButton.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 30);
    fbButton.readPermissions = @[@"public_profile", @"email"];
    fbButton.delegate = self;
    [self.view addSubview:fbButton];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard)];
    [self.view addGestureRecognizer:tap];
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
            if (error == nil) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) res;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([httpResponse statusCode] == 200) {
                        //User has been verified
                        [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
                        [[NSUserDefaults standardUserDefaults] setValue:_passwordField.text forKey:@"password"];
                        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        User *user = [[User alloc] initWithDictionary:dict];
                        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        del.activeUser = user;
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        //NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        [self showErrorMessage:_errorLabel andMessage:[NSHTTPURLResponse localizedStringForStatusCode: [httpResponse statusCode]]];
                    }
                });
            } else {
                [self showErrorMessage:_errorLabel andMessage:[error localizedDescription]];
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

#pragma mark - FBSDK integration
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error == nil){
        if (result){
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email" forKey:@"fields"];
            FBSDKGraphRequest *req = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            [req startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id res, NSError *error) {
                if(error == nil) {
                    [self validateFacebookUser];
                } else {
                    [self showErrorMessage:_errorLabel andMessage:[error localizedDescription]];
                }
            }];
        }
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    //Nothing for now
}

-(void) validateFacebookUser {
    id block = ^{
        NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/auth/facebook/token"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        NSError* error = nil;
        NSDictionary *dict = @{
                               @"access_token" : fbAccessToken
                               };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        request.HTTPBody = jsonData;
        [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error == nil) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    if ([httpResponse statusCode] == 200){
                        //User exists in database
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        //should we navigate to register scene here?
                        [self showErrorMessage:_errorLabel andMessage:[NSHTTPURLResponse localizedStringForStatusCode: [httpResponse statusCode]]];
                    }
                } else {
                    [self showErrorMessage:_errorLabel andMessage:[error localizedDescription]];
                }
            });
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}
#pragma mark - END FBSDK integration

#pragma mark - UITextField delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}

-(void)dismissTheKeyboard{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark - validation
-(void)showErrorMessage:(UILabel *)field andMessage:(NSString *)message{
    //Set the text field to fully transparent
    [field setAlpha:0.0f];
    //Set the text equal to the message provided as an argument
    field.text = message;
    
    //fade in
    [UIView animateWithDuration:.7f animations:^{
        //Set the text field to fully non-transparent
        [field setAlpha:1.0f];
        //Completion block is called after the animation has completed
    } completion:^(BOOL finished) {
        //fade out
        [UIView animateWithDuration:1.f delay:1.5f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [field setAlpha:0.0f];
        } completion:nil];
    }];
}

#pragma mark - Navigation
- (IBAction)backPressed:(id)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
}

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
