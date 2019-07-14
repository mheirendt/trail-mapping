//
//  ProfileViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peopleFollowers = [[NSMutableArray alloc] init];
    self.peopleFollowing = [[NSMutableArray alloc] init];
    _imagePicker.delegate = self;
    [self setupUser];
    [_avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFriendsView:) name:@"friendsViewDismissed" object:nil];
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self setupUser];
}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) setupUser {
    if (!self.isViewingOtherProfile) {
        id block = ^{
            NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/profile"];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.f];
            request.HTTPMethod = @"GET";
            [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
            
            NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        _user = [[User alloc] initWithDictionary:dict];
                        self.username.text = _user.username;
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
                        //MM d, ''yy
                        //YYYY mm dd hh mm ss SSSS
                        //NSDate *d = [dateFormatter dateFromString:_user.created];
                        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                        //NSString *date = [dateFormatter stringFromDate:_user.created];
                        //NSString *joinedText = [@"Member since: " stringByAppendingString:date];
                        //self.joined.text = joinedText;
                        self.followers.text = [NSString stringWithFormat:@"%lu", (unsigned long)_user.followers.count];
                        self.following.text = [NSString stringWithFormat:@"%lu", (unsigned long)_user.following.count];
                        
                        [self setupProfilePic];
                    });
                }
            }];
            [dataTask resume];
        };
        //Create a Grand Central Dispatch queue and run the operation async
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, block);
    } else {
        [self setupProfilePic];
        self.username.text = _user.username;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
        //MM d, ''yy
        //YYYY mm dd hh mm ss SSSS
        //NSDate *d = [dateFormatter dateFromString:_user.created];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        //NSString *date = [dateFormatter stringFromDate:_user.created];
        //NSString *joinedText = [@"Member since: " stringByAppendingString:date];
        //self.joined.text = joinedText;
        self.followers.text = [NSString stringWithFormat:@"%lu", (unsigned long)_user.followers.count];
        self.following.text = [NSString stringWithFormat:@"%lu", (unsigned long)_user.following.count];
    }
}

- (void) setupProfilePic {
    if (_user.avatar) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:_user.avatar];
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
            if ( data == nil )
            return;
            dispatch_async(dispatch_get_main_queue(), ^{
                _avatar.image = [UIImage imageWithData:data];
            });
        });
    }
}


- (IBAction)viewFollowing:(id)sender {
    [self showFriendsView:_user.following];
}
- (IBAction)viewFollowers:(id)sender {
    [self showFriendsView:_user.followers];
}
- (IBAction)addOrRemoveFriend:(id)sender {
        _followButton.enabled = false;
        id block = ^{
            
            NSURL* url;
            if ([_followButton.titleLabel.text isEqualToString:@"Follow"]) {
                url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/follow/userId"];
            } else {
                url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/unfollow/userId"];
            }
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
            request.HTTPMethod = @"POST";
            [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_user._id, @"userId", nil];
            NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
            request.HTTPBody = data;
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        User *user = [[User alloc] initWithDictionary:dict];
                        _user = user;
                        if ([_followButton.titleLabel.text isEqualToString:@"Follow"]) {
                            [_followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                        } else {
                            [_followButton setTitle:@"Follow" forState:UIControlStateNormal];
                        }
                        _followButton.enabled = true;
                        [self setupUser];
                    });
                    
                }else{
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }];
            [dataTask resume];
        };
        //Create a Grand Central Dispatch queue and run the operation async
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, block);
}

-(void)showFriendsView:(NSMutableArray *) users {
    _backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = .5f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFriendsView:)];
    [_backgroundView addGestureRecognizer:recognizer];
    [self.view addSubview:_backgroundView];
    //if (!_friendsView){
    _friendsView = [[FriendsView alloc] initWithFrame:CGRectMake(0, 0, 250, 375)];
    _friendsView.backgroundColor = [UIColor whiteColor];
    CGRect viewBounds = self.view.bounds;
    _friendsView.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds) - 70);
    _friendsView.layer.borderWidth = 1.5f;
    _friendsView.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    _friendsView.users = [NSMutableArray array];
    _friendsView.users = users;
    //}
    [self.view addSubview:_friendsView];
}

-(void) dismissFriendsView:(NSNotification *)notification {

    [self.friendsView removeFromSuperview];
    [UIView animateWithDuration:0.5 delay:0.f options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 0;
    }
                     completion:^(BOOL finished){
                         [self.backgroundView removeFromSuperview];
                     }];
    if ([notification isKindOfClass:[NSNotification class]] && ![[notification object] isKindOfClass:[UIButton class]]) {
        id block = ^{
            User *user = (User *)[notification object];
            NSURL* url = [NSURL URLWithString:[@"https://secure-garden-50529.herokuapp.com/user/search/username/" stringByAppendingString:user.username]];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
            request.HTTPMethod = @"GET";
            [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                        _user = [[User alloc] initWithDictionary:dict];
                        [self setupUser];
                    });
                }else{
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }];
            [dataTask resume];
        };
        //Create a Grand Central Dispatch queue and run the operation async
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, block);
    }
}


-(IBAction) changeProfileImage:(id)sender {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:_imagePicker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
        [_params setObject:[NSString stringWithFormat:@"%d", _user.userID] forKey:@"userId"];
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
                _user.avatar = [dataDict objectForKey:@"avatar"];
                NSDictionary* avatarDict = [_user toDictionary];
                    NSURL* updateURL = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/update"];
                    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:updateURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
                    request.HTTPMethod = @"PUT";
                    //NSDictionary *avatarDict = @{ @"avatar" : str };
                    NSError *error = nil;
                    NSData *avatarData = [NSJSONSerialization dataWithJSONObject:avatarDict options:NSJSONWritingPrettyPrinted error:&error];
                    request.HTTPBody = avatarData;
                    [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
                    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
                    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
                    NSURLSessionDataTask* dTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (!error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            if ([httpResponse statusCode] == 200){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _image = originalImage;
                                    [_avatar setImage:_image];
                                    [self.view setNeedsDisplay];
                                });
                            }
                            
                        } else
                            NSLog(@"%@", error.localizedDescription);
                        
                    }];
                [dTask resume];
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
    }


@end
