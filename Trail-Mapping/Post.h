//
//  Post.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/7/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ProfileViewController.h"
@class Post;
@class Comment;

@protocol MHPostDelegate <NSObject>
@optional - (void) viewPostDetail:(Post *)post isCommenting:(bool)isCommenting;
@end

@interface Post : UIView <UIGestureRecognizerDelegate>

//UI
@property (strong, retain) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *bodyView;
@property (strong, retain) IBOutlet UIImageView *avatar;
@property (strong, retain) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIImageView *likeIcon;
@property (strong, retain) IBOutlet UILabel *likesLabel;
@property (strong, retain) IBOutlet UILabel *commentsLabel;

//Model
@property (nonatomic, strong) id<MHPostDelegate> delegate;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) UIImageView *image;
@property (retain, strong) NSString *_id;
@property (retain, strong) NSDictionary *submittedUser;
@property (retain, strong) NSDictionary* reference;
@property (retain, strong) NSMutableArray* likes;
@property (retain, strong) NSString* comments;
@property (retain, strong) NSDate* created;

- (void)setupProfilePic:(NSString *)urlStr;
-(void) setDictionary:(NSDictionary *)dictionary;
- (NSDictionary*) toDictionary;
- (void) persist:(Post*)post;
-(bool) checkLikes;
-(void) viewProfile;
-(void) postLikeFor: (NSString *) postId type: (NSNumber *)type typeId: (NSString *) typeId;
-(void) postCommentFor: (NSString *) postId body: (NSString *) body type: (NSNumber *)type comment: (Comment *) comment;

@end
