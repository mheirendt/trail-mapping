//
//  RegisterScene.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface RegisterScene : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordReEntryField;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UILabel *emailWarning;
@property (weak, nonatomic) IBOutlet UILabel *usernameWarning;
@property (weak, nonatomic) IBOutlet UILabel *password1Warning;
@property (weak, nonatomic) IBOutlet UILabel *password2Warning;

@end
