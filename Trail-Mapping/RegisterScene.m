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
    id block = ^ {
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/signup"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.timeoutInterval = 10.f;
        request.HTTPMethod = @"POST";
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.usernameField.text forKey:@"username"];
        [dict setObject:self.passwordField.text forKey:@"password"];
        [dict setObject:self.emailField.text forKey:@"email"];
        _imageID ? [dict setObject: self.imageID forKey:@"avatar"] : nil;
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
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
                    } else {
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
                    //Upload the user's facebook profile picture as an avatar by default
                    NSString *fbid = [res objectForKey:@"id"];
                    dispatch_async(dispatch_get_global_queue(0,0), ^{
                        NSString *urlStr = [@"http://graph.facebook.com/%@/picture?type=small" stringByAppendingString:fbid];
                        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                        //if ( data == nil )
                        //return;
                        //dispatch_async(dispatch_get_main_queue(), ^{
                            [self uploadImageData:data];
                        //});
                    });
                    [self.emailField setText:[res objectForKey:@"email"]];
                    //self.facebookPassword = [res objectForKey:@"id"];
                    //disable password field
                    [_passwordField setEnabled:NO];
                    [_usernameField becomeFirstResponder];
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
    //NSString *fbAccessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/auth/facebook/token"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.HTTPMethod = @"POST";
    NSError* error = nil;
    NSDictionary *dict = @{
                           @"username" : self.usernameField.text,
                           @"avatar" : self.imageID,
                           @"email" : self.emailField.text
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
        //Completion block
        if (error == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode] == 200){
                //User exists in database
                //_facebookPassword = fbAccessToken;
                //[[NSUserDefaults standardUserDefaults] setValue:self.facebookPassword forKey:@"facebook"];
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
        } else {
            [self showErrorMessage:_errorLabel andMessage:[error localizedDescription]];
        }
    }];
    [dataTask resume];
    
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
    [self uploadImageData:imageData];
}

-(void) uploadImageData:(NSData *)imageData {
    id block = ^{
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
                if (self.imageID) {
                    NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:_imageID];
                    NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _avatar.image = [UIImage imageWithData:data];
                    });
                }
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
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

