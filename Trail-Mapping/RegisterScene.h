//
//  RegisterScene.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "loginScene.h"

@interface RegisterScene : UIViewController <UITextFieldDelegate, FBSDKLoginButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@property (weak, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageID;

@property BOOL flag;
@property (strong, nonatomic) NSString *facebookUsername;
@property (strong, nonatomic) NSString *facebookEmail;
@property (strong, nonatomic) NSString *facebookPassword;
@property (strong, nonatomic) NSString *facebookPhoto;
@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UIButton *toggleSigninButton;

@property (strong, nonatomic) User* storedUser;

@property (strong, nonatomic) NSMutableArray *errorDesc;



-(void)showErrorMessage:(UILabel *)field andMessage:(NSString *)message;

@end
