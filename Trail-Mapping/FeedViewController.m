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
    self.scrollView.delegate = self;
    /*
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
     */
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFeed];
}

-(void)updateFeed {
    id block = ^{
        self.posts = [[NSMutableArray alloc] init];
        NSURL* url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/posts"];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"GET";
        [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                NSMutableArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (int i = 0; i < responseArray.count; i++) {
                        FeedPost *currentPost = [[FeedPost alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
                        [currentPost setDictionary:[responseArray objectAtIndex:i]];
                        CGFloat yOrigin = i * 210;
                        [currentPost setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, 200)];
                        [self.posts addObject:currentPost];
                        [self.scrollView addSubview:currentPost];
                    }
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, -10, -10);
                    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 210 * self.posts.count)];
                    [self.view setNeedsDisplay];
                    [self.scrollView setNeedsDisplay];
                    NSLog(@"%lu", (unsigned long)self.posts.count);
                });

            }else{
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
    
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

@end
