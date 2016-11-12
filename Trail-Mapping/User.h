//
//  User.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSNumber *score;
@property int userID;

-(NSDictionary *)toDictionary;

- (void) persist:(User*)user;
- (User *)initWithEmail:(NSString *)email Username:(NSString *)username Password:(NSString *)password;
@end