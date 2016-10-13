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
    self.emailField.delegate = self;
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.passwordReEntryField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard)];
    [self.view addGestureRecognizer:tap];
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
- (IBAction)dismissVIew:(id)sender {
    User *user = [[User alloc] initWithEmail:_emailField.text Username:_usernameField.text Password:_passwordField.text];
    [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)switchToSignin:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"signin" forKey:@"signin"];
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}

@end
