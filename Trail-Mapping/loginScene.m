//
//  loginScene.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/9/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "loginScene.h"

@interface loginScene ()

@end

@implementation loginScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)userSignIn:(id)sender {
}
- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)validateUser:(id)sender{
    NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/login"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSDictionary *dict = @{
                           @"username" : _usernameField.text,
                           @"password" : _passwordField.text,
                           };
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    request.HTTPBody = jsonData;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
        //Completion block
        if (error == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) res;
            NSLog(@"response status code: %lu", [httpResponse statusCode]);
            if ([httpResponse statusCode] == 200) {
                //User has been verified
                [[NSUserDefaults standardUserDefaults] setValue:_usernameField.text forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
                //[self dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                //user has not been verified
            };
        } else {
            NSLog(@"Something went wrong: %@", [error localizedDescription]);
        }
    }];
    [dataTask resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
