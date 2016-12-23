//
//  FeedPost.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "FeedPost.h"

@interface FeedPost ()
@property (strong, nonatomic) IBOutlet UIView *view;

@end

@implementation FeedPost
@synthesize view, avatar, username, bodyText, comment, dislikeButton, likeButton;
- (void)viewDidLoad {
    //[super viewDidLoad];

}
/*
+ (FeedPost *) initWithOptions:(UIImage*)avatar username:(NSString*)username textBody:(NSString*)textBody {
    //FeedPost *post = [[FeedPost alloc] initWithNibName:@"FeedPost" bundle:[NSBundle mainBundle]];
    //FeedPost *post = [[FeedPost alloc] init];
    //FeedPost *post = [[[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil] objectAtIndex:0];
    FeedPost *post = [[FeedPost alloc] initWithFrame:CGRectMake(0,0,0,0)];
    //[[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil];
    //[self addSubview:self.view];
    //[post.view addSubview:view];
    post.username = [[UILabel alloc] init];
    post.bodyText = [[UILabel alloc] init];
    post.avatar = [[UIImageView alloc] initWithImage:avatar];
    post.username.text = username;
    post.bodyText.text = textBody;
    
    return post;
}
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code.
        //
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        UITapGestureRecognizer *inquire = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfile)];
        [self.view addGestureRecognizer:tap];
        
        [self.username addGestureRecognizer:inquire];
        [self.avatar addGestureRecognizer:inquire];
        [[NSBundle mainBundle] loadNibNamed:@"FeedPost" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyboard];
    return YES;
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
            
            ProfileViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"profile"];
            vc.username.text = name;
            vc.avatar = [[UIImageView alloc] initWithImage:image];
            vc.followers.text = [NSString stringWithFormat:@"%d", followersCount];
            vc.following.text = [NSString stringWithFormat:@"%d", followingCount];
            vc.peopleFollowers = followers;
            vc.peopleFollowing = following;
            //self.navigationController.definesPresentationContext= YES;
            //[self.navigationController pushViewController:vc animated:YES];
        }
    }];
    [dataTask resume];
}

- (void)dismissKeyboard {
    [self.comment resignFirstResponder];
}


@end
