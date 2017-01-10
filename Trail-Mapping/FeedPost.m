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
        
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        UITapGestureRecognizer *viewDetails = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPost)];
        UITapGestureRecognizer *inquire = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewProfile)];
        inquire.delegate = self;
        //[self addGestureRecognizer:inquire];
        self.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
        self.headerView.userInteractionEnabled = YES;
        self.avatar.userInteractionEnabled = YES;
        //self.avatarTapGesture.delegate = self.avatar;
        //self.avatarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile)];
        //[self.username addGestureRecognizer:inquire];
        [self addGestureRecognizer:viewDetails];
        //[self.username addGestureRecognizer:inquire];
        [[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil];
        [self addSubview:self.view];
         
    }
    return self;
}
 

- (void)viewPost {
    //FeedPostDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FeedPostDetailViewController"];
    //vc.feedPost = self;
    //[vc zoomToPath:_path];
    //ProfileViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"profile"];
    
    [self.parent viewPostDetail:self];
}
- (void)viewProfile {
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

- (IBAction)comment:(id)sender {
}
- (IBAction)like:(id)sender {
}

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
    //self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_likes.count];//[NSString stringWithFormat:@"%lu Likes", _likes.count];
    //self.commentsLabel.text = [NSString stringWithFormat:@"%lu Comments", _comments.count];
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
