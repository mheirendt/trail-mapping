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
    self.errorDesc = [NSMutableArray array];
    
    [_avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
}
-(void)dismissTheKeyboard{
    [self.emailField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dismissView {
    //User *user = [[User alloc] initWithEmail:_emailField.text Username:_usernameField.text Password:_passwordField.text];
    [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setValue:_passwordField.text forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
    //[user persist:user];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:NO completion:^{
        //[self dismissViewControllerAnimated:NO completion:nil];
    //}];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboards when the user selects the 'Return' button
    [self dismissTheKeyboard];
    return YES;
}
-(void)validateFacebookUser {
    NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    //NSLog(@"This is token: %@", fbAccessToken);
    NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/auth/facebook/token"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.HTTPMethod = @"POST";
    NSError* error = nil;
    NSDictionary *dict = @{
                           @"username" : self.facebookUsername,
                           @"access_token" : fbAccessToken,
                           @"avatar" : self.facebookPhoto
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
        if (error == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode] == 200){
                //User exists in database
                _facebookPassword = fbAccessToken;
                [[NSUserDefaults standardUserDefaults] setValue:self.facebookPassword forKey:@"facebook"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                //dismiss the popup (temporary fix)
                [self dismissViewControllerAnimated:YES completion:^{
                    //dismiss the sign in view
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
        }
        else {
            NSLog(@"error: %@", error.localizedDescription);
        }
    }];
    [dataTask resume];
    
}
- (IBAction)validate:(id)sender {
    id block = ^ {
        
        self.flag = YES;
        [self.errorDesc removeAllObjects];
        //NSURL* url = [NSURL URLWithString:[@"https://secure-garden-50529.herokuapp.com/signup"  stringByAppendingPathComponent:self.usernameField.text]];
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/signup"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.timeoutInterval = 10.f;
        request.HTTPMethod = @"POST";
        NSDictionary *dict = @{
                               @"username" : self.usernameField.text,
                               @"password" : self.passwordField.text,
                               @"email"    : self.emailField.text,
                               @"avatar"   : self.imageID
                               };
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        NSString* myString;
        myString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        //NSLog(@"%@", myString);
        request.HTTPBody = jsonData;
        [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    if ([httpResponse statusCode] == 200){
                        AppDelegate *del;
                        del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        del.activeUser = [[User alloc] initWithDictionary:dict];
                        [self dismissView];
                        
                    }
                });
                    
                    /*id block = ^{
                     NSDictionary* userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                     User *user = [[User alloc] initWithDictionary:userDict];
                     // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
                     NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
                     [_params setObject:@"1.0" forKey:@"ver"];
                     [_params setObject:@"en" forKey:@"lan"];
                     [_params setObject:[NSString stringWithFormat:@"%d", user.userID] forKey:@"userId"];
                     [_params setObject:[NSString stringWithFormat:@"recfile"] forKey:@"title"];
                     
                     // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
                     NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
                     
                     // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
                     NSString* FileParamConstant = @"recfile";
                     
                     // the server url to which the image (or the media) is uploaded. Use your server url here
                     NSURL* requestURL = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/upload"];
                     
                     // create request
                     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                     [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                     [request setHTTPShouldHandleCookies:NO];
                     [request setTimeoutInterval:30];
                     [request setHTTPMethod:@"POST"];
                     
                     // set Content-Type in HTTP header
                     NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
                     [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
                     
                     // post body
                     NSMutableData *body = [NSMutableData data];
                     
                     // add params (all params are strings)
                     for (NSString *param in _params) {
                     [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
                     [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
                     }
                     
                     // add image data
                     NSData *imageData = UIImageJPEGRepresentation(_image, .2f);
                     if (imageData) {
                     [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                     [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                     [body appendData:imageData];
                     [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                     }
                     
                     [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
                     
                     // setting the body of the post to the reqeust
                     [request setHTTPBody:body];
                     
                     // set the content-length
                     NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
                     [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                     
                     // set URL
                     [request setURL:requestURL];
                     
                     [request setHTTPBody:body];
                     
                     NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
                     NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
                     NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                     if (!error) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                     NSDictionary* avatarDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                     _imageID = [avatarDict objectForKey:@"avatar"];
                     });
                     } else
                     NSLog(@"Error: %@", [error localizedDescription]);
                     }];
                     [dataTask resume];
                     };
                     //Create a Grand Central Dispatch queue and run the operation async
                     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                     dispatch_async(queue, block);
                     }
                     }
                     }];
                     [dataTask resume];*/
            }
        }];
        [dataTask resume];

    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
    
    
    }

        /*
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
         */
        /*
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
            //}
        //}else{
            //NSLog(@"Error: %@", [error localizedDescription]);
            }
         */
                                      

/*
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
 */
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
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email" forKey:@"fields"];
            FBSDKGraphRequest *req = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            [req startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id res, NSError *error) {
                if(error == nil)
                {
                    
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Username" message:@"Please Select a username." preferredStyle:UIAlertControllerStyleAlert];
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
        self.helpLabel.text = @"Need to create a profile?";
        [self.signinButton setTitle:@"Create a Profile" forState:UIControlStateNormal];
    } else {
        self.titleLabel.text = @"Create a Profile";
        self.emailLabel.hidden = NO;
        self.emailField.hidden = NO;
        self.helpLabel.text = @"Already have a profile?";
        [self.signinButton setTitle:@"Sign in Here" forState:UIControlStateNormal];
    }
}
//- (IBAction)selectAvatar:(id)sender {
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
    _image = nil;
    _image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(_image==nil)
        _image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(_image==nil)
        _image = [info objectForKey:UIImagePickerControllerCropRect];
    
    id block = ^{
        //Create a UIImage from the picker
        UIImage* originalImage = nil;
        originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if(originalImage==nil)
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(originalImage==nil)
        originalImage = [info objectForKey:UIImagePickerControllerCropRect];
        //Create an API Request
        
        // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
        NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
        [_params setObject:@"1.0" forKey:@"ver"];
        [_params setObject:@"en" forKey:@"lan"];
        //[_params setObject:[NSString stringWithFormat:@"%d", _user.userID] forKey:@"userId"];
        [_params setObject:[NSString stringWithFormat:@"recfile"] forKey:@"title"];
        
        // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
        NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
        
        // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
        NSString* FileParamConstant = @"recfile";
        
        // the server url to which the image (or the media) is uploaded. Use your server url here
        NSURL* requestURL = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/upload"];
        
        // create request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // post body
        NSMutableData *body = [NSMutableData data];
        
        // add params (all params are strings)
        for (NSString *param in _params) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        // add image data
        NSData *imageData = UIImageJPEGRepresentation(originalImage, .2f);
        if (imageData) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // set the content-length
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        // set URL
        [request setURL:requestURL];
        
        [request setHTTPBody:body];
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (!error) {
                NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                self.imageID = [dataDict objectForKey:@"avatar"];
                NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:_imageID];
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _avatar.image = [UIImage imageWithData:data];
                });
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

- (IBAction)backPressed:(id)sender {
[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
}

@end
