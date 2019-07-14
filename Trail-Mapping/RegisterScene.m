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
    [self.avatar setUserInteractionEnabled:YES];
    UITapGestureRecognizer *uploadPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadPhoto)];
    [self.avatar addGestureRecognizer:uploadPhoto];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTheKeyboard)];
    [self.view addGestureRecognizer:tap];
    [_avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
}

- (IBAction)validate:(id)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.usernameField.text forKey:@"username"];
    [dict setObject:self.passwordField.text forKey:@"password"];
    [dict setObject:self.emailField.text forKey:@"email"];
    _imageID ? [dict setObject: self.imageID forKey:@"avatar"] : nil;
    User *user = [[User alloc] initWithDictionary:dict];
    [user persist:dict completionBlock:^(NSData * data){
        if (data != nil)
        {
            AppDelegate *del;
            del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            del.activeUser = [[User alloc] initWithDictionary:dict];
            [self dismissView];
        }
        else
        {
            [self showErrorMessage:_errorLabel andMessage:@"An error occurred"];
        }
    }];
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
                    //Upload the user's facebook profile picture as an avatar by default
                    NSString *fbid = [res objectForKey:@"id"];
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        NSString *urlStr = [@"http://graph.facebook.com/%@/picture?type=small" stringByAppendingString:fbid];
                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                        [[[User alloc] init] uploadImageData:imageData completionBlock:^(NSData * data)
                         {
                             if (data != nil)
                             {
                                 NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                 self.imageID = [dataDict objectForKey:@"avatar"];
                                 if (self.imageID) {
                                     NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:_imageID];
                                     NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         _avatar.image = [UIImage imageWithData:data];
                                     });
                                 }
                             }
                             else
                                 [self showErrorMessage:_errorLabel andMessage:@"An error occurred"];
                         }];
                    });
                    [self.emailField setText:[res objectForKey:@"email"]];
                    //self.facebookPassword = [res objectForKey:@"id"];
                    //disable password field
                    [_passwordField setEnabled:NO];
                    [_usernameField becomeFirstResponder];
                    _IsCreatingUsername = true;
                } else {
                    [self showErrorMessage:_errorLabel andMessage:[error localizedDescription]];
                }
            }];
        }
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

-(void)validateFacebookUser {
    NSDictionary *dict = @{
                           @"username" : self.usernameField.text,
                           @"email" : self.emailField.text
                           };
    //TODO: image?
    [[[User alloc] initWithDictionary:dict] signupWithFacebook:dict completionBlock:^(NSData * data)
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
        {
            _IsCreatingUsername = true;
            [_usernameField becomeFirstResponder];
            [self showErrorMessage:_errorLabel andMessage:@"An error occurred"];
        }
    }];
}
#pragma mark - END FBSDK integration
#pragma mark - image uploading
-(void) uploadPhoto {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    //Create a UIImage from the picker
    _pickedImage = nil;
    _pickedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(_pickedImage==nil)
        _pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(_pickedImage==nil)
        _pickedImage = [info objectForKey:UIImagePickerControllerCropRect];
    NSData *imageData = UIImageJPEGRepresentation(_pickedImage, .2f);
    [[[User alloc] init] uploadImageData:imageData completionBlock:^(NSData * data)
    {
        if (data != nil)
        {
            NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            self.imageID = [dataDict objectForKey:@"avatar"];
            if (self.imageID) {
                NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:_imageID];
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _avatar.image = [UIImage imageWithData:data];
                });
            }
        }
        else
            [self showErrorMessage:_errorLabel andMessage:@"An error occurred"];
    }];
}
#pragma mark - END image uploading
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

#pragma mark - text field delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}

-(void)dismissTheKeyboard{
    [self.emailField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    if (_IsCreatingUsername)
        [self validateFacebookUser];
}

#pragma mark - navigation
- (IBAction)backPressed:(id)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
}

- (IBAction)switchToSignIn:(id)sender {
    NSLog(@"nav controller to login");
}

- (void)dismissView {
    [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setValue:_passwordField.text forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end


 //[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small", fbid];
 /*UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Username" message:@"Please Select a username." preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *okAction = [UIAlertAction
 actionWithTitle:NSLocalizedString(@"OK", @"OK action")
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction *action)
 {
 NSString *fbid = [res objectForKey:@"id"];
 UITextField *login = controller.textFields.firstObject;
 self.facebookUsername = login.text;
 self.facebookEmail = [res objectForKey:@"email"];
 self.facebookPassword = [res objectForKey:@"id"];
 self.facebookPhoto = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small", fbid];
 [self validateFacebookUser];
 }];
 [controller addTextFieldWithConfigurationHandler:^(UITextField *textField)
 {
 textField.placeholder = NSLocalizedString(@"LoginPlaceholder", @"Login");
 }];
 
 [controller addAction:okAction];
 [self presentViewController:controller animated:YES completion:nil];*/

