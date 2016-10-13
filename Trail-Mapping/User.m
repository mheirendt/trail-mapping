//
//  User.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "User.h"

@implementation User
-(User *)initWithEmail:(NSString *)email Username:(NSString *)username Password:(NSString *)password{
    User *user = [[User alloc] init];
    user.email = email;
    user.username = username;
    user.password = password;
    return user;
}
@end
