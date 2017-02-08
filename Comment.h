//
//  Comments.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/6/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "FeedPostDetail.h"
@class FeedPostDetail;

@protocol MHCommentDelegate <NSObject>
- (void)buildComments:(bool)adding;
@end


@interface Comment : UIView

@property (strong, retain) NSDictionary *comment;

@property (strong, retain) UIImageView *avatar;
@property (strong, retain) UILabel *username;
@property (strong, retain) UILabel *bodyLabel;
@property (strong, retain) UILabel *createdLabel;
@property (strong, retain) UIImageView *likeIcon;
@property (strong, retain) UILabel *likesLabel;
@property (strong, retain) UIImageView *repliesIcon;
@property (strong, retain) UILabel *repliesLabel;
@property (nonatomic, weak) id<MHCommentDelegate> delegate;
@property (strong, nonatomic) FeedPostDetail *parent;

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSDictionary *submittedUser;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *postId;
@property (strong, nonatomic) NSArray *likes;
@property (strong, nonatomic) NSArray *replies;
@property (strong, nonatomic) NSDate *created;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (void) postLikeFor: (NSString *) postId type: (NSNumber *)type;
- (void) setDictionary:(NSDictionary *)dictionary;
- (bool) checkLikes;

@end
