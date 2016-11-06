//
//  User.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "User.h"

#define safeSet(d,k,v) if (v) d[k] = v;

@implementation User
-(User *)initWithEmail:(NSString *)email Username:(NSString *)username Password:(NSString *)password{
    User *user = [[User alloc] init];
    user.email = email;
    user.username = username;
    user.password = password;
    user.score = [NSNumber numberWithInt:0];
    return user;
}

- (NSDictionary*) toDictionary
{
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    //safeSet(jsonable, @"userID", self.userID);
    safeSet(jsonable, @"username", self.username);
    safeSet(jsonable, @"password", self.password);
    safeSet(jsonable, @"email", self.email);
    safeSet(jsonable, @"score", self.score);
    
    
    return jsonable;
}

- (void) persist:(User*)user
{
    
    //NSString* users = @"https://secure-garden-50529.herokuapp.com/users";
    ///local-reg
    NSString* users = @"https://secure-garden-50529.herokuapp.com/local-reg";
    
    //BOOL isExistingLocation = path._id != nil;
    NSURL* url = [NSURL URLWithString:users];
    NSDictionary *dictionary = [user toDictionary];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Posted");
        } else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [dataTask resume];
}
@end
