//
//  FeedPost.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "FeedPost.h"

#define safeSet(d,k,v) if (v) d[k] = v;

@interface FeedPost ()
@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation FeedPost

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *inquire = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)];
        inquire.delegate = self;
        self.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        self.headerView.userInteractionEnabled = YES;
        self.bodyView.userInteractionEnabled = YES;
        self.avatar.userInteractionEnabled = YES;
        [_avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
        [self addGestureRecognizer:inquire];
        [[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil];
        [self addSubview:self.view];
         
    }
    return self;
}

- (void)setupProfilePic:(NSString *)urlStr {
    if ([_submittedUser valueForKey:@"avatar"]) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSString *urlString = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:[_submittedUser valueForKey:@"avatar"]];
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlString]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
            _avatar.image = [UIImage imageWithData:data];
            });
        });
    }
}

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
            UIFont *currentFont = _likeButton.titleLabel.font;
            [_likeButton.titleLabel setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize]];
            [_likeIcon setImage:[UIImage imageNamed:@"likePressed"]];
            return YES;
        }
    }
    [_likeIcon setImage:[UIImage imageNamed:@"like"]];
    return NO;
}

#pragma mark - UITapGestureRecognizer input mapping
- (void)handleTouch: (UITapGestureRecognizer *)tapRecognizer {
    CGPoint touchPoint = [tapRecognizer locationInView:self];
    NSLog(@"point: %f, %f", touchPoint.x, touchPoint.y);
    if (touchPoint.y < 75) {
        [self viewProfile];
    } else if (touchPoint.y > 250 && touchPoint.y  < 280) {
        if (touchPoint.x < 122) {
            //Like
            [self viewLikes];
        } else if (touchPoint.x > 275) {
            //Share
            //[self postShare];
        } else {
            //Comment
            [self.parent viewPostDetail:self isCommenting:true];
        }
        
    } else if (touchPoint.y > 280) {
        if (touchPoint.x < 122) {
            //View Likes
            [self postLikeFor: self._id type: [NSNumber numberWithInt:1] typeId: nil];
        } else if (touchPoint.x > 275) {
            //Share
            [self postShare];
        } else {
            //Comment
            [self.parent viewPostDetail:self isCommenting:true];
        }
    } else {
        [self.parent viewPostDetail:self isCommenting:false];
    }
}

-(void) viewProfile {
    id block = ^(void) {
        NSString* urlstr = [NSString stringWithFormat:@"https://secure-garden-50529.herokuapp.com/user/search/username/%@", [self.submittedUser valueForKey:@"username"]];
        NSURL* url = [NSURL URLWithString:urlstr];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"GET";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *   error) {
            if (error){
                NSLog(@"error: %@", [error localizedDescription]);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageNamed:@"Bike"];
                    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    NSString* name = [dict objectForKey:@"username"];
                    NSString* imgURLstr;
                    if ([dict objectForKey:@"avatar"]){
                        imgURLstr = [dict objectForKey:@"avatar"];
                    }
                    NSMutableArray* followers = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"followers"]];
                    NSMutableArray* following = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"following"]];
                    int followersCount = (int)[followers count];
                    int followingCount = (int)[following count];
                    UIImageView *profilePic = [[UIImageView alloc] initWithImage:image];
                    
                    ProfileViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"profile"];
                    vc.username.text = name;
                    vc.avatar = profilePic;
                    vc.followers.text = [NSString stringWithFormat:@"%d", followersCount];
                    vc.following.text = [NSString stringWithFormat:@"%d", followingCount];
                    vc.peopleFollowers = followers;
                    vc.peopleFollowing = following;
                    
                    [self.parent.navigationController pushViewController:vc animated:YES];
                    
                    //[self.parent presentViewController:vc animated:YES completion:nil];
                });
                
            }
        }];
        [dataTask resume];
    };
    
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}
-(void) viewLikes {
    _parent.backgroundView = [[UIView alloc]initWithFrame:self.parent.view.frame];
    _parent.backgroundView.backgroundColor = [UIColor blackColor];
    _parent.backgroundView.alpha = .5f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:_parent action:@selector(dismissFriendsView:)];
    [_parent.backgroundView addGestureRecognizer:recognizer];
    [_parent.view addSubview:_parent.backgroundView];
    _parent.friendsView = [[FriendsView alloc] initWithFrame:CGRectMake(0, 0, 250, 375)];
    _parent.friendsView.backgroundColor = [UIColor whiteColor];
    CGRect viewBounds = self.parent.view.bounds;
    _parent.friendsView.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds) - 70);
    _parent.friendsView.layer.borderWidth = 1.5f;
    _parent.friendsView.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    _parent.friendsView.users = [NSMutableArray array];
    _parent.friendsView.users = _likes;
    [_parent.view addSubview:_parent.friendsView];
}
-(void) postLikeFor: (NSString *) postId type: (NSNumber *)type typeId: (NSString *) typeId {
    id block = ^(void) {
        NSString *urlstr;
        bool check = [self checkLikes];
        if (check) {
            urlstr = @"https://secure-garden-50529.herokuapp.com/posts/unlike";
        } else {
            urlstr = @"https://secure-garden-50529.herokuapp.com/posts/like";
        }
        NSURL* url = [NSURL URLWithString:urlstr];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", postId ] forKey:@"post"];
        [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        typeId ? [dictionary setObject:typeId forKey:@"typeId"] : nil;
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

-(void) postCommentFor: (NSString *) postId body: (NSString *) body type: (NSNumber *)type comment: (Comment *) comment {
    id block = ^(void) {
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/posts/comment"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", postId ] forKey:@"post"];
        type ? [dictionary setObject:type forKey:@"type"] : nil;
        [dictionary setObject:body forKey:@"body"];
        comment ? [dictionary setObject:comment._id forKey:@"typeId"] : nil;
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
                    [self.commentsLabel setText:[dict objectForKey:@"comments"]];
                    //[self setDictionary:dict];
                    //[self setNeedsDisplay];
                    [comment.delegate buildComments:true];
                });
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

-(void) postShare {
    id block = ^(void) {
        NSString* urlstr = [NSString stringWithFormat:@"https://secure-garden-50529.herokuapp.com/user/search/username/%@", self.username.text];
        NSURL* url = [NSURL URLWithString:urlstr];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"GET";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *   error) {
            if (error){
                NSLog(@"error: %@", [error localizedDescription]);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

#pragma mark - helper methods

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
    if (![[_reference objectForKey:@"_id" ] isEqualToString:[dictionary objectForKey:@"reference"]]) {
        _reference = dictionary[@"reference"];
    }
    if (![_body isEqualToString:[dictionary objectForKey:@"body"]]) {
        _body = dictionary[@"body"];
    }
    if (![_likes isEqualToArray:[dictionary objectForKey:@"likes"]]) {
        _likes = dictionary[@"likes"];
    }
    if ([_comments isEqualToString:[dictionary objectForKey:@"comments"]]) {
        _comments = dictionary[@"comments"];
    }
    if (![_created isEqual:[dictionary objectForKey:@"created"]]) {
        _created = dictionary[@"created"];
    }
    
    User *user = [[User alloc] initWithDictionary:_submittedUser];
    Path *path = [[Path alloc] initWithDictionary:_reference];
    
    [self setupCategoryIcons:path.categories];

    self.bodyText.text = _body;
    self.username.text = user.username;
    self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_likes.count];//[NSString stringWithFormat:@"%lu Likes", _likes.count];
    self.commentsLabel.text = [NSString stringWithFormat:@"%@ Comments", _comments];
    [self checkLikes];
}

-(void) setupCategoryIcons:(NSArray *) categories {
    for (int i = 0; i < categories.count; i++) {
        NSString *cat = categories[i];
        i == 0 ? self.imageCenter.image = [UIImage imageNamed:cat] : nil;
        i == 1 ? self.imageLeft1.image = [UIImage imageNamed:cat] : nil;
        i == 2 ?self.imageRight1.image = [UIImage imageNamed:cat] : nil;
        i == 3 ?self.imageLeft2.image = [UIImage imageNamed:cat] : nil;
        i == 4 ?self.imageRight2.image = [UIImage imageNamed:cat] : nil;
    }
}


- (NSDictionary*) toDictionary {
    
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"submittedUser", self.submittedUser);
    safeSet(jsonable, @"reference", self.reference);
    safeSet(jsonable, @"body", self.body);
    safeSet(jsonable, @"likes", self.likes);
    safeSet(jsonable, @"comments", self.comments);
    safeSet(jsonable, @"created", self.created);
    
    return jsonable;
}

- (void) persist:(FeedPost*)post
{
    NSString* posts = @"https://secure-garden-50529.herokuapp.com/posts";
    NSURL* url = [NSURL URLWithString:posts];
    NSDictionary *dictionary = [post toDictionary];
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

@implementation TrailPost


@end

@implementation AnnotationPost


@end

@implementation GenericPost


@end

@implementation PhotoPost


@end



