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
@synthesize view, avatar, username, bodyText/*, likeButton, commentButton*/;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code.
        //
        
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        UITapGestureRecognizer *inquire = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile)];
        //[self addGestureRecognizer:inquire];
        
        //self.parent = (UIViewController)
        [self.username addGestureRecognizer:inquire];
        [self.avatar addGestureRecognizer:inquire];
        [[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}
- (IBAction)comment:(id)sender {
}
- (IBAction)like:(id)sender {
}

-(id) initWithDictionary:(NSDictionary *)dictionary frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        /////INIT WITH FRAME METHODS
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        UITapGestureRecognizer *inquire = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile)];
        //[self addGestureRecognizer:inquire];
        [self.username addGestureRecognizer:inquire];
        [self.avatar addGestureRecognizer:inquire];
        //[[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil];
        //[self addSubview:self.view];
        
        ////IMPORT METHODS
        NSArray * arr = [dictionary allKeys];
        NSLog(@"dict: %@", arr);
        __id = dictionary[@"_id"];
        _submittedUser = dictionary[@"submittedUser"];
        _body = dictionary[@"body"];
        _likes = dictionary[@"likes"];
        _comments = dictionary[@"comments"];
        _created = dictionary[@"created"];
        
        self.bodyText.text = _body;
        self.username.text = _submittedUser.username;
        //self.likesLabel.text = [NSString stringWithFormat:@"%lu Likes", _likes.count];
        //self.commentsLabel.text = [NSString stringWithFormat:@"%lu Comments", _comments.count];
    }
    return self;
}

- (NSDictionary*) toDictionary {
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"submittedUser", self.submittedUser);
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


-(void) showUserProfile {
    NSString* urlstr = [NSString stringWithFormat:@"https://secure-garden-50529.herokuapp.com/user/search/username/%@", self.username.text];
    NSURL* url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
        if (error){
            NSLog(@"error: %@", [error localizedDescription]);
        } else {
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
            
            self.parent.definesPresentationContext= YES;
            [self.parent presentViewController:vc animated:YES completion:nil];
        }
    }];
    [dataTask resume];
}


@end
