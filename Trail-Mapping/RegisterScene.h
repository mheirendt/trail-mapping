//
//  RegisterScene.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface RegisterScene : UIViewController <UITextFieldDelegate, FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *passwordREEntryLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordReEntryField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UILabel *emailWarning;
@property (weak, nonatomic) IBOutlet UILabel *usernameWarning;
@property (weak, nonatomic) IBOutlet UILabel *password1Warning;
@property (weak, nonatomic) IBOutlet UILabel *password2Warning;
@property BOOL flag;
@property (strong, nonatomic) NSString *facebookUsername;
@property (strong, nonatomic) NSString *facebookEmail;
@property (strong, nonatomic) NSString *facebookPassword;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UIButton *toggleSigninButton;

@property (strong, nonatomic) NSMutableArray *errorDesc;



-(void)showErrorMessage:(UILabel *)field andMessage:(NSString *)message;

@end
