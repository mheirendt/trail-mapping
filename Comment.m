//
//  Comments.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/6/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *viewTouched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discernCommentAction:)];
        [self addGestureRecognizer:viewTouched];
        self.userInteractionEnabled = YES;
        
        
        //Avatar
        _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 50, 50)];
        [_avatar.layer setCornerRadius:25];
        _avatar.clipsToBounds = YES;
        [_avatar.layer setBorderWidth:2.f];
        [_avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
        
        [self addSubview:_avatar];
        
        //Username label
        _username = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 15)];
        [_username setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",@"Helvetica"] size:17.f]];
        [self addSubview:_username];
        
        //Body label
        _bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, self.frame.size.width, self.frame.size.height - 90)];
        _bodyLabel.numberOfLines = 100;
        //[_body sizeToFit];
        _bodyLabel.lineBreakMode = NSLineBreakByClipping;
        _bodyLabel.text = [_bodyLabel.text stringByAppendingString:@"\n\n\n\n\n\n"];
        [self addSubview:_bodyLabel];
        
        
        //Separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(50, 110, self.frame.size.width - 100, 1)];
        [separator.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
        [self addSubview:separator];
        
        //created label
        _createdLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 115, 120, 20)];
        [_createdLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.f]];
        //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sssZ"];
        
        //NSString *dateObj = [NSString stringWithFormat:@"%@", [_post.comments[i] objectForKey:@"created"]];
        
        //NSDate *parsedDate = [formatter dateFromString:dateObj];
        //NSLog(@"========= REal Date %@", parsedDate);
        
        //NSString *lastUpdate = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
        //[_created setText:dateObj];
        [self addSubview:_createdLabel];
        
        //Separator dot
        UIView *separatorIcon = [[UIView alloc] initWithFrame:CGRectMake(_createdLabel.frame.origin.x + _createdLabel.frame.size.width + 5, 125, 4, 4)];
        [separatorIcon.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
        separatorIcon.layer.cornerRadius = 2.f;
        separatorIcon.clipsToBounds = YES;
        [self addSubview:separatorIcon];
        
        //like
        UIImageView *likeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(separatorIcon.frame.origin.x + 15, 115, 20, 20)];
        [likeIcon setImage:[UIImage imageNamed:@"like"]];
        [likeIcon setUserInteractionEnabled:YES];
        [self addSubview:likeIcon];
        UILabel *like = [[UILabel alloc] initWithFrame:CGRectMake(likeIcon.frame.origin.x + 40, 110, 30, 30)];
        [like setText:@"Like"];
        [like setFont:[UIFont fontWithName:@"Helvetica" size:12.f]];
        [self addSubview:like];
        
        //Reply
        UIImageView *commentIcon = [[UIImageView alloc] initWithFrame:CGRectMake(like.frame.origin.x + like.frame.size.width + 40, 118, 20, 20)];
        [commentIcon setImage:[UIImage imageNamed:@"comment"]];
        [self addSubview:commentIcon];
        UILabel *reply = [[UILabel alloc] initWithFrame:CGRectMake(commentIcon.frame.origin.x + 40, 110, 30, 30)];
        [reply setText:@"reply"];
        [reply setFont:[UIFont fontWithName:@"Helvetica" size:12.f]];
        [self addSubview:reply];
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        __id = dictionary[@"_id"];
        _body = dictionary[@"body"];
        _likes = dictionary[@"likes"];
        _replies = dictionary[@"replies"];
        _created = dictionary[@"created"];
    }
    
    return self;
}


-(void)discernCommentAction:(UIGestureRecognizer *)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self];
    NSLog(@"point: %f, %f", touchPoint.x, touchPoint.y);
    if (touchPoint.y > 80) {
        if (touchPoint.x > 142 && touchPoint.x < 170) {
            //Liked
            [self postLikeFor:__id type:[NSNumber numberWithInt:2]];
            //[self likeComment:(Comment*)self];
            
            
        } else if (touchPoint.x > 109 && touchPoint.x < 251) {
            //view likes
            [self viewCommentLikes:(Comment *)self];
        } else if (touchPoint.x > 250) {
            //Reply
            self.parent.isReplying = true;
            self.parent.typeId = [self.comment objectForKey:@"_id"];
            [self.parent.chatBox becomeFirstResponder];
        } else {
            //View likes
        }
    }
}


-(void) postLikeFor: (NSString *) postId type: (NSNumber *)type {
    id block = ^(void) {
        NSString *urlstr;
        bool check = [self checkLikes];
        if (check) {
            urlstr = @"https://secure-garden-50529.herokuapp.com/comments/unlike";
        } else {
            urlstr = @"https://secure-garden-50529.herokuapp.com/comments/like";
        }
        NSURL* url = [NSURL URLWithString:urlstr];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", postId ] forKey:@"post"];
        [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
        request.HTTPBody = data;
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *   error) {
            if (error){
                NSLog(@"error: %@", [error localizedDescription]);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    [self setDictionary:dict];
                    [self setNeedsDisplay];
                    [self checkLikes];
                });
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}


/*
 -(void) likeComment: (Comment *) view {
 [view.likeIcon setImage:[UIImage imageNamed:@"likePressed"]];
 }*/

-(bool) checkLikes {
    for (int i = 0; i < _likes.count; i++) {
        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSDictionary *dict = _likes[i];
        NSString *dictID;
        if ([dict isKindOfClass:[NSString class]]) {
            dictID = (NSString *)dict;
        } else {
            dictID = [dict objectForKey:@"_id"];
        }
        if ([del.activeUser._id isEqualToString:dictID]) {
            //UIFont *currentFont = _likeButton.titleLabel.font;
            //[_likeButton.titleLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize]];
            //[_likeIcon setImage:[UIImage imageNamed:@"likePressed"]];
            [_likeIcon setImage:[UIImage imageNamed:@"likePressed"]];
            return YES;
        }
    }
    [_likeIcon setImage:[UIImage imageNamed:@"like"]];
    return NO;
}

-(void) setDictionary:(NSDictionary *)dictionary {
    if (![__id isEqualToString:[dictionary objectForKey:@"_id"]]) {
        __id = dictionary[@"_id"];
    }
    if (![[_submittedUser objectForKey:@"_id"] isEqualToString:[dictionary objectForKey:@"submittedUser"]]) {
        _submittedUser = dictionary[@"submittedUser"];
        if ([_submittedUser objectForKey:@"avatar" ]) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:[_submittedUser objectForKey:@"avatar" ]];
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_avatar setImage:[UIImage imageWithData:data]];
                });
            });
        }
    }
    if (![_postId isEqualToString:[dictionary objectForKey:@"postId"]]) {
        _postId = dictionary[@"postId"];
    }
    if (![_body isEqualToString:[dictionary objectForKey:@"body"]]) {
        _body = dictionary[@"body"];
    }
    if (![_likes isEqualToArray:[dictionary objectForKey:@"likes"]]) {
        _likes = dictionary[@"likes"];
    }
    if (![_replies isEqualToArray:[dictionary objectForKey:@"replies"]]) {
        _replies = dictionary[@"replies"];
    }
    if (![_created isEqual:[dictionary objectForKey:@"created"]]) {
        _created = dictionary[@"created"];
    }
    
    User *user = [[User alloc] initWithDictionary:_submittedUser];
    
    self.bodyLabel.text = _body;
    self.username.text = user.username;
    self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_likes.count];//[NSString stringWithFormat:@"%lu Likes", _likes.count];
    [self checkLikes];
}

-(void) viewCommentLikes: (Comment *) view {
    self.parent.backgroundView = [[UIView alloc]initWithFrame:self.parent.view.frame];
    self.parent.backgroundView.backgroundColor = [UIColor blackColor];
    self.parent.backgroundView.alpha = .5f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.parent action:@selector(dismissFriendsView:)];
    [self.parent.backgroundView addGestureRecognizer:recognizer];
    [self.parent.view addSubview:self.parent.backgroundView];
    self.parent.friendsView = [[FriendsView alloc] initWithFrame:CGRectMake(0, 0, 250, 375)];
    self.parent.friendsView.backgroundColor = [UIColor whiteColor];
    CGRect viewBounds = self.parent.view.bounds;
    self.parent.friendsView.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds) - 70);
    self.parent.friendsView.layer.borderWidth = 1.5f;
    self.parent.friendsView.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    self.parent.friendsView.users = [NSMutableArray array];
    self.parent.friendsView.users = [view.comment objectForKey:@"likes"];
    [self.parent.view addSubview:self.parent.friendsView];
}

@end
