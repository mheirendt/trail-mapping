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

# pragma mark - UITapGestureRecognizer input mapping
- (void)handleTouch: (UITapGestureRecognizer *)tapRecognizer {
    CGPoint touchPoint = [tapRecognizer locationInView:self];
    NSLog(@"point: %f, %f", touchPoint.x, touchPoint.y);
    if (touchPoint.y < 75) {
        [self viewProfile];
    } else if (touchPoint.y > 250 && touchPoint.y  < 280) {
        if (touchPoint.x < 122) {
            //Like
            [self postLike];
        } else if (touchPoint.x > 275) {
            //Share
            [self postShare];
        } else {
            //Comment
            [self postComment];
        }
        
    } else if (touchPoint.y > 280) {
        if (touchPoint.x < 122) {
            //View Likes
            [self postLike];
        } else if (touchPoint.x > 275) {
            //Share
            [self postShare];
        } else {
            //Comment
            [self postComment];
        }
    } else {
        [self viewPost:false];
    }
}

- (void)viewPost:(bool)commentFlag {
    FeedPostDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FeedPostDetailViewController"];
    if (commentFlag) {
        //[vc showCommentView];
    }
    //vc.feedView = self;
    //[vc zoomToPath:_path];
    
    [self.parent viewPostDetail:self];
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

-(void) postLike {
    id block = ^(void) {
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/posts/like"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", self._id ] forKey:@"post"];
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
                });
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}
-(void) postComment {
    [self viewPost:true];
}

-(void) submitComment:(NSString *) body {
    id block = ^(void) {
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/posts/comment"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", self._id ] forKey:@"post"];
        [dictionary setObject:body forKey:@"body"];
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
    
    NSArray *arr = [dictionary allKeys];
    NSLog(@"dict: %@", arr);
    __id = dictionary[@"_id"];
    _submittedUser = dictionary[@"submittedUser"];
    _reference = dictionary[@"reference"];
    _body = dictionary[@"body"];
    _likes = dictionary[@"likes"];
    _comments = dictionary[@"comments"];
    _created = dictionary[@"created"];
    
    User *user = [[User alloc] initWithDictionary:_submittedUser];
    Path *path = [[Path alloc] initWithDictionary:_reference];
    
    int count = (int)[path.categories count];
    
    if (count == 1) {
        NSString *cat = path.categories[0];
        if ([cat isEqualToString:@"Bike"]) {
            self.imageCenter.image = [UIImage imageNamed:@"Bike"];
        }
    }

    self.avatar.image = [UIImage imageNamed:@"Bike"];
    self.bodyText.text = _body;
    self.username.text = user.username;
    self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_likes.count];//[NSString stringWithFormat:@"%lu Likes", _likes.count];
    self.commentsLabel.text = [NSString stringWithFormat:@"%lu Comments", _comments.count];
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
         [_avatar.layer setBackgroundColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];

         [self addSubview:_avatar];
        
         //Username label
         _username = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 15)];
         [_username setFont:[UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",@"Helvetica"] size:17.f]];
         [self addSubview:_username];
         
         //Body label
         _body = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, self.frame.size.width, self.frame.size.height - 90)];
         _body.numberOfLines = 100;
         //[_body sizeToFit];
         _body.lineBreakMode = NSLineBreakByClipping;
         _body.text = [_body.text stringByAppendingString:@"\n\n\n\n"];
         [self addSubview:_body];
        
        
        //Separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(50, 110, self.frame.size.width - 100, 1)];
         [separator.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
         [self addSubview:separator];
         
         //created label
         _created = [[UILabel alloc] initWithFrame:CGRectMake(10, 115, 120, 20)];
         [_created setFont:[UIFont fontWithName:@"Helvetica" size:12.f]];
         //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         //[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sssZ"];
         
         //NSString *dateObj = [NSString stringWithFormat:@"%@", [_post.comments[i] objectForKey:@"created"]];
         
         //NSDate *parsedDate = [formatter dateFromString:dateObj];
         //NSLog(@"========= REal Date %@", parsedDate);
         
         //NSString *lastUpdate = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
         //[_created setText:dateObj];
         [self addSubview:_created];
         
         //Separator dot
         UIView *separatorIcon = [[UIView alloc] initWithFrame:CGRectMake(_created.frame.origin.x + _created.frame.size.width + 5, 125, 4, 4)];
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


-(void)discernCommentAction:(UIGestureRecognizer *)recognizer {
    
}

@end


