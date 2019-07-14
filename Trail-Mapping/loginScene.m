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
    NSDictionary *dict = @{
                           @"username" : _usernameField.text,
                           @"password" : _passwordField.text,
                           };
    [[[User alloc] initWithDictionary:dict] login:dict completionBlock:^(NSData * data){
        if (data != nil)
        {
            //User has been verified
            [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setValue:_passwordField.text forKey:@"password"];
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            User *user = [[User alloc] initWithDictionary:dict];
            AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            del.activeUser = user;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [self showErrorMessage:_errorLabel andMessage:@"An error occurred"];
        }
    }];
}
#pragma mark end region
#pragma mark facebook delegate methods
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error == nil){
        if (result){
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email" forKey:@"fields"];
            FBSDKGraphRequest *req = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            [req startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id res, NSError *error) {
                if(error == nil)
                {
                    [[[User alloc] init] loginWithFacebook:^(NSData * data)
                    {
                        if (data != nil)
                        {
                            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                            User *user = [[User alloc] initWithDictionary:dict];
                            AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            del.activeUser = user;
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                        else
                            [self showErrorMessage:_errorLabel andMessage:@"An error occurred"];
                    }];
                }
                else
                    [self showErrorMessage:_errorLabel andMessage:[error localizedDescription]];
            }];
        }
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    //Nothing for now
}
#pragma mark end region
#pragma mark text field delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}

-(void)dismissTheKeyboard{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
#pragma mark end region
#pragma mark validation
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
#pragma mark end region
#pragma mark navigation
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
#pragma mark end region
@end
