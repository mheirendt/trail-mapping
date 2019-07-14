//
//  User.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface User : NSObject
@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSMutableArray *following;
@property (strong, nonatomic) NSMutableArray *followers;
@property int userID;

-(NSDictionary *)toDictionary;

- (void) persist:(NSDictionary *)dictionary completionBlock:(void(^)(NSData *)) completionBlock;
-(void) login:(NSDictionary *)dictionary completionBlock:(void(^)(NSData *)) completionBlock;
-(void) signupWithFacebook:(NSDictionary *)dictionary completionBlock:(void(^)(NSData *)) completionBlock;
-(void) loginWithFacebook:(void(^)(NSData *)) completionBlock;
- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (User *)initWithEmail:(NSString *)email Username:(NSString *)username avatar:(NSString *)avatar Password:(NSString *)password;
-(void) uploadImageData:(NSData *)imageData completionBlock:(void(^)(NSData *)) completionBlock;
@end
