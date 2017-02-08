//
//  FeedPost.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//
#import "AppDelegate.h"
#import "FeedViewController.h"
#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "FeedPostDetail.h"
#import "User.h"
#import "Path.h"
#import "Comment.h"
//TODO
@class Comment;
@class FeedViewController;

@interface FeedPost : UIView <UIGestureRecognizerDelegate>

//UI
@property (strong, retain) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *bodyView;
@property (strong, retain) IBOutlet UIImageView *avatar;
@property (strong, retain) IBOutlet UILabel *username;
@property (strong, retain) IBOutlet UILabel *bodyText;
@property (weak, nonatomic) IBOutlet UIImageView *likeIcon;
@property (strong, retain) IBOutlet UIButton *likeButton;
@property (strong, retain) IBOutlet UIButton *commentButton;
@property (strong, retain) IBOutlet UILabel *likesLabel;
@property (strong, retain) IBOutlet UILabel *commentsLabel;
@property (strong, retain) IBOutlet UIImageView *imageCenter;
@property (strong, retain) IBOutlet UIImageView *imageLeft1;
@property (strong, retain) IBOutlet UIImageView *imageLeft2;
@property (strong, retain) IBOutlet UIImageView *imageRight1;
@property (strong, retain) IBOutlet UIImageView *imageRight2;
@property (strong, retain) IBOutlet UILabel *tagsLabel;
@property (strong, retain) FeedViewController *parent;

//Model
@property (retain, strong) NSString *_id;
@property (retain, strong) NSDictionary *submittedUser;
@property (retain, strong) NSDictionary* reference;
@property (retain, strong) NSString* body;
@property (retain, strong) NSMutableArray* likes;
@property (retain, strong) NSString* comments;
@property (retain, strong) NSDate* created;

@property (retain, strong) Path *path;

- (void)setupProfilePic:(NSString *)urlStr;
-(void) setDictionary:(NSDictionary *)dictionary;
-(bool) checkLikes;
- (NSDictionary*) toDictionary;
- (void) persist:(FeedPost*)post;
-(void) viewProfile;
-(void) postLikeFor: (NSString *) postId type: (NSNumber *)type typeId: (NSString *) typeId;
-(void) postCommentFor: (NSString *) postId body: (NSString *) body type: (NSNumber *)type comment: (Comment *) comment;

@end

@interface TrailPost : FeedPost

@end

@interface AnnotationPost : FeedPost

@end

@interface GenericPost : FeedPost

@end

@interface PhotoPost : FeedPost

@end

