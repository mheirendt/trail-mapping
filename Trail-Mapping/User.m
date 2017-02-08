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
-(User *)initWithEmail:(NSString *)email Username:(NSString *)username avatar:(NSString *)avatar Password:(NSString *)password{
    User *user = [[User alloc] init];
    user.email = email;
    user.username = username;
    user.avatar = avatar;
    user.password = password;
    user.score = [NSNumber numberWithInt:0];
    return user;
}

- (instancetype) initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        __id = dictionary[@"_id"];
        _email = dictionary[@"email"];
        _username = dictionary[@"username"];
        _avatar = dictionary[@"avatar"];
        _score = dictionary[@"score"];
        _created = dictionary[@"created"];
        _followers = dictionary[@"followers"];
        _following = dictionary[@"following"];
    }
    return self;
}

- (NSDictionary*) toDictionary
{
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"username", self.username);
    safeSet(jsonable, @"avatar", self.avatar);
    safeSet(jsonable, @"password", self.password);
    safeSet(jsonable, @"email", self.email);
    safeSet(jsonable, @"score", self.score);
    safeSet(jsonable, @"followers", self.followers);
    safeSet(jsonable, @"following", self.following);
    
    return jsonable;
}

- (void) persist:(User*)user
{
    id block = ^{
        NSString* users = @"https://secure-garden-50529.herokuapp.com/local-reg";
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
                
            } else{
                
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}
@end
