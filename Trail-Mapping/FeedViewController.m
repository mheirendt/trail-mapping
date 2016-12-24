//
//  FeedViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/13/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "FeedViewController.h"

@interface FeedViewController ()

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView.delegate = self;
    NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/profile"];
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
            NSURL *imageURL; //= [NSURL URLWithString:@"https://scontent.xx.fbcdn.net/v/t1.0-1/p200x200/13528956_1275521285792762_6593284762910932365_n.jpg?oh=26f24fa76f0f37050e6e184cfaac3e3d&oe=58BDB28A"];
            NSLog(@"response: %@", res);
            NSDictionary* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            //for (NSDictionary* item in responseArray) {
                if ([responseArray objectForKey:@"avatar"]){
                    NSLog(@"yas");
                    imageURL = [NSURL URLWithString:[responseArray objectForKey:@"avatar"]];
                }
            //}
            //UIImage* avatar = [UIImage imageWith]
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *avatar = [UIImage imageWithData:imageData];
            UIImageView* imageView = [[UIImageView alloc] initWithImage:avatar];
            imageView.frame = CGRectMake(0, 0, 200, 200);
            imageView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
            [self.view addSubview:imageView];
        }
    }];
    [dataTask resume];
    
    [self updateFeed];
}

-(void)updateFeed {
    //TODO: GET request to retrieve all posts of current user and following
    self.posts = [[NSMutableArray alloc] init];
    UIImage *image = [UIImage imageNamed:@"Bike"];
    FeedPost *post = [[FeedPost alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,200)];
    post.avatar.image = image;
    post.username.text = @"mikey7896";
    post.avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bike"]];
    post.bodyText.text = @"This is the first awesome post!";
    post.parent = self;
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UITapGestureRecognizer *inquire = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    //[self.view addGestureRecognizer:tap];
    
    [post.username addGestureRecognizer:inquire];
    [post.avatar addGestureRecognizer:inquire];
    
    [self.posts addObject:post];
    
    UIImage *image2 = [UIImage imageNamed:@"Run"];
    //FeedPost *post2 = [[FeedPost alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,200)];
    FeedPost *post2 = [[FeedPost alloc] initWithFrame:CGRectMake(0,0,/*self.view.bounds.size.width*/self.view.bounds.size.width,200)];
    post2.avatar.image = image2;
    post2.username.text = @"mikey7896";
    post2.bodyText.text = @"second test post on the feed wall";
    post2.parent = self;
    
    [post2.username addGestureRecognizer:inquire];
    [post2.avatar addGestureRecognizer:inquire];
    
    [self.posts addObject:post2];
    
    UIImage *image3 = [UIImage imageNamed:@"Skate"];
    FeedPost *post3 = [[FeedPost alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,200)];
    post3.avatar.image = image3;
    post3.username.text = @"another";
    post3.bodyText.text = @"and finally a third";
    
    [post3.username addGestureRecognizer:inquire];
    [post3.avatar addGestureRecognizer:inquire];
    post3.parent = self;
    
    [self.posts addObject:post3];
    
    [self setUpScrollView];
}
-(void)tap {
    NSLog(@"taptap");
}

-(void)setUpScrollView {
    for (int i = 0; i < self.posts.count; i++) {
        FeedPost *currentPost = [self.posts objectAtIndex:i];
        CGFloat yOrigin = i * 220;
        [currentPost setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, 200)];
        [self.scrollView addSubview:currentPost];
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(5, 5, -10, -10);
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 220 * self.posts.count)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signOut:(id)sender {
    //TODO: post to appURL/logout to register with server
    NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/logout"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.HTTPMethod = @"POST";
    [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
        //Completion block
        if (error == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) res;
            NSLog(@"response status code: %lu", (long)[httpResponse statusCode]);
            //if ([httpResponse statusCode] == 200) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebook"];
                [[NSUserDefaults standardUserDefaults] setObject:@"signin" forKey:@"signin"];
                [self.tabBarController setSelectedIndex:0];
            //} else {
                //NSLog(@"%ld", (long)[httpResponse statusCode]);
                //user has not been verified
            //};
        } else {
            NSLog(@"Something went wrong: %@", [error localizedDescription]);
            //if ([httpResponse statusCode] == 200) {
            [[NSUserDefaults standardUserDefaults] setObject:@"signin" forKey:@"signin"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebook"];
            [self.tabBarController setSelectedIndex:0];
        }
    }];
    [dataTask resume];
}
- (IBAction)viewProfile:(id)sender {
    NSString* urlstr = @"https://secure-garden-50529.herokuapp.com/user/profile";
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
            NSString* username = [dict objectForKey:@"username"];
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
            vc.username.text = username;
            vc.avatar = profilePic;
            vc.followers.text = [NSString stringWithFormat:@"%d", followersCount];
            vc.following.text = [NSString stringWithFormat:@"%d", followingCount];
            vc.peopleFollowers = followers;
            vc.peopleFollowing = following;
            self.navigationController.definesPresentationContext= YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    [dataTask resume];
}

#pragma mark - scroll view delegate methods
//-(void)scroll

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - scroll view delegate methods
- (void)dismissKeyboard {
    //[self.comment resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyboard];
    return YES;
}

@end
