//
//  RegisterScene.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "RegisterScene.h"

@interface RegisterScene ()

@end

@implementation RegisterScene

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBSDKLoginButton *fbButton = [[FBSDKLoginButton alloc] init];
    fbButton.center = CGPointMake(self.view.center.x, self.view.bounds.size.height - 30);
    fbButton.readPermissions = @[@"public_profile", @"email"];
    fbButton.delegate = self;
    [self.view addSubview:fbButton];
    self.emailField.delegate = self;
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordReEntryField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard)];
    [self.view addGestureRecognizer:tap];
    self.errorDesc = [NSMutableArray array];
}
-(void)dismissTheKeyboard{
    [self.emailField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.passwordReEntryField resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismissView {
    User *user = [[User alloc] initWithEmail:_emailField.text Username:_usernameField.text Password:_passwordField.text];
    [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
    [user persist:user];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}
-(void)validateFacebookUser {
    NSURL* url = [NSURL URLWithString:[@"https://secure-garden-50529.herokuapp.com/users/"  stringByAppendingPathComponent:self.facebookUsername]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //Completion block
        if (error == nil) {
            NSLog(@"error is nil");
            if (response.expectedContentLength < 5){
                NSLog(@"should be saved");
                User *user = [[User alloc] initWithEmail:self.facebookEmail Username:self.facebookUsername Password:nil];
                [[NSUserDefaults standardUserDefaults] setValue:self.facebookUsername forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                [user persist:user];
                [self dismissViewControllerAnimated:YES completion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                
            } else {
                //Todo : inform the user to come up with a new name
                NSLog(@"should not be");
                //[self.errorDesc addObject:@"duplicate username"];
            }
        }
    }];
    [dataTask resume];
}
- (IBAction)validate:(id)sender {
    self.flag = YES;
    [self.errorDesc removeAllObjects];
    NSURL* url = [NSURL URLWithString:[@"https://secure-garden-50529.herokuapp.com/users/"  stringByAppendingPathComponent:self.usernameField.text]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //Completion block
        if (error == nil) {
            NSLog(@"error is nil");
            if (response.expectedContentLength < 5){
                NSLog(@"should be saved");
                self.flag = YES;
            } else {
                NSLog(@"should not be");
                [self.errorDesc addObject:@"duplicate username"];
                self.flag = NO;
            }
            
            //validate fields
            if (_usernameField.text.length < 1){
                [self.errorDesc addObject:@"empty username"];
                self.flag = NO;
            }
            if (_passwordField.text.length < 1){
                [self.errorDesc addObject:@"empty password"];
                self.flag = NO;
            }
            if (_passwordReEntryField.text.length < 1){
                [self.errorDesc addObject:@"empty second password"];
                self.flag = NO;
            }
            if (![_passwordField.text isEqualToString:_passwordReEntryField.text]){
                [self.errorDesc addObject:@"must match"];
                self.flag = NO;
            }
            if (self.emailField.text.length < 9 || ![self.emailField.text containsString:@"@"]){
                [self.errorDesc addObject:@"invalid email"];
                self.flag = NO;
            }
            
            if (self.flag){
                [self dismissView];
            } else {
                for (NSString *error in self.errorDesc){
                    NSLog(@"errorS");
                    if ([error isEqualToString:@"invalid email"]){
                        if (self.emailField.text.length < 9){
                            [self showErrorMessage:self.emailWarning andMessage:@"You must enter an email address"];
                        } else {
                            [self showErrorMessage:self.emailWarning andMessage:@"You must enter a valid email"];
                        }
                    }
                    if ([error isEqualToString:@"empty username"]){
                        [self showErrorMessage:self.usernameWarning andMessage:@"Your must enter a username."];
                    }
                    if ([error isEqualToString:@"empty password"]){
                        [self showErrorMessage:self.password1Warning andMessage:@"Your must enter a password."];
                    }
                    if ([error isEqualToString:@"empty second password"]){
                        [self showErrorMessage:self.password2Warning andMessage:@"Your must enter a password."];
                    }
                    if ([error isEqualToString:@"must match"]){
                        [self showErrorMessage:self.password1Warning andMessage:@"Passwords must match."];
                        [self showErrorMessage:self.password2Warning andMessage:@"Passwords must match."];
                    }
                    if ([error isEqualToString:@"duplicate username"]){
                        [self showErrorMessage:self.usernameWarning andMessage:@"Your selected username is already taken."];
                    }
                }
            }
        }else{
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    [dataTask resume];
}
-(void)handleErrors{
    NSLog(@"handling");
    for (NSString *error in self.errorDesc){
        NSLog(@"errorS");
        if ([error isEqualToString:@"invalid email"]){
            if (self.emailField.text.length < 9){
                 [self showErrorMessage:self.emailWarning andMessage:@"You must enter an email address"];
            } else {
                [self showErrorMessage:self.emailWarning andMessage:@"You must enter a valid email"];
            }
        }
        if ([error isEqualToString:@"empty username"]){
            [self showErrorMessage:self.usernameWarning andMessage:@"Your must enter a username."];
        }
        if ([error isEqualToString:@"empty password"]){
            [self showErrorMessage:self.password1Warning andMessage:@"Your must enter a password."];
        }
        if ([error isEqualToString:@"empty second password"]){
            [self showErrorMessage:self.password2Warning andMessage:@"Your must enter a password."];
        }
        if ([error isEqualToString:@"must match"]){
            [self showErrorMessage:self.password1Warning andMessage:@"Passwords must match."];
            [self showErrorMessage:self.password2Warning andMessage:@"Passwords must match."];
        }
        if ([error isEqualToString:@"duplicate username"]){
            [self showErrorMessage:self.usernameWarning andMessage:@"Your selected username is already taken."];
        }
    }
}
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

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    if (error == nil){
        if (result){
            FBSDKGraphRequest *req = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObjectsAndKeys: @"email",@"fields",@"name", @"fields",nil]];
            [req startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if(error == nil)
                {
                    NSLog(@"result: %@", result);
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Username" message:@"Please Select a username." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSLog(@"OK action");
                                                   UITextField *login = controller.textFields.firstObject;
                                                   self.facebookUsername = login.text;
                                                   self.facebookEmail = [result objectForKey:@"email"];
                                                   [self validateFacebookUser];
                                               }];
                    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField)
                     {
                         textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Login");
                     }];
                    
                    [controller addAction:okAction];
                    [self presentViewController:controller animated:YES completion:nil];
                    
                }
                else
                {
                    NSLog(@"error: %@", error);
                }
            }];
            
            //[self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}


- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}



- (IBAction)switchToSignIn:(id)sender {
    if ([self.titleLabel.text isEqualToString:@"Create a Profile"]){
        self.titleLabel.text = @"Sign In";
        self.emailLabel.hidden = YES;
        self.emailField.hidden = YES;
        self.passwordREEntryLabel.hidden = YES;
        self.passwordReEntryField.hidden = YES;
        self.helpLabel.text = @"Need to create a profile?";
        [self.signinButton setTitle:@"Create a Profile" forState:UIControlStateNormal];
    } else {
        self.titleLabel.text = @"Create a Profile";
        self.emailLabel.hidden = NO;
        self.emailField.hidden = NO;
        self.passwordREEntryLabel.hidden = NO;
        self.passwordReEntryField.hidden = NO;
        self.helpLabel.text = @"Already have a profile?";
        [self.signinButton setTitle:@"Sign in Here" forState:UIControlStateNormal];
    }
}

@end
