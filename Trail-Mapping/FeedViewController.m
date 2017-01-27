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
    searchResultsTable *table = [[searchResultsTable alloc] init];
    self.scrollView.delegate = self;
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(updateFeed:) forControlEvents:UIControlEventValueChanged];
    [_scrollView addSubview:_refreshControl];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:table];
    _searchController.delegate = self;
    _searchController.searchBar.delegate = table;
    _searchController.searchResultsUpdater = table;
    _searchController.hidesNavigationBarDuringPresentation = false;
    _searchController.dimsBackgroundDuringPresentation = true;
    _searchController.searchBar.placeholder = @"Search for users";
    //TODO: create cg size for searchBar ... possibly hidden until search button is pressed
    [_searchController.searchBar sizeToFit];
    self.definesPresentationContext = true;
    self.navigationItem.titleView = _searchController.searchBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSearchController) name:@"searchControllerRefresh" object:nil];

}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateFeed:_refreshControl];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFeed:_refreshControl];
}
- (void) stretchToSuperView:(UIView*) view {
    /*view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString *formatTemplate = @"%@:|[view]|";
    for (NSString * axis in @[@"V"]) {
        NSString * format = [NSString stringWithFormat:formatTemplate,axis];
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        [view.superview.superview addConstraints:constraints];
    }*/
    //view.superview.superview.translatesAutoresizingMaskIntoConstraints = NO;
    //view.superview.translatesAutoresizingMaskIntoConstraints = NO;
    //view.translatesAutoresizingMaskIntoConstraints = NO;
    
    /*NSDictionary *views = @{
                            @"subview":view,
                            @"parent":self.scrollView
                            };*/
    //[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[parent]-0-|" options:0 metrics:nil views:views]];
    //[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[subview]|" options:0 metrics:nil views:views]];
    //[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview(==parent)]" options:0 metrics:nil views:views]];
    
}

-(void)updateFeed:(UIRefreshControl *)refreshControl {
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating feed..."];
    [refreshControl beginRefreshing];
    id block = ^{
        [refreshControl beginRefreshing];
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
                        FeedPost *currentPost = [[FeedPost alloc] initWithFrame:CGRectMake(0, self.refreshControl.frame.size.height, self.scrollView.frame.size.width, 300)];
                        [currentPost setDictionary:[responseArray objectAtIndex:i]];
                        User *user = [[User alloc] initWithDictionary:currentPost.submittedUser];
                        [currentPost setupProfilePic:user.avatar];
                        currentPost.parent = self;
                        CGFloat yOrigin = i * 330;
                        [currentPost setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width,  300)];
                        [self.posts addObject:currentPost];
                        [self.scrollView addSubview:currentPost];
                        [self stretchToSuperView:currentPost];
                    }
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, -10, -10);
                    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 330 * self.posts.count)];
                    [self.view setNeedsDisplay];
                    [self.scrollView setNeedsDisplay];
                    //UIRefreshController interface
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM d, h:mm a"];
                    NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
                    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
                    //[refreshControl endRefreshing];
                    [refreshControl endRefreshing];
                    [_scrollView setContentInset:UIEdgeInsetsZero];
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
    id block = ^{
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
            dispatch_async(dispatch_get_main_queue(), ^{
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
            });
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
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

-(void) refreshSearchController {
    searchResultsTable *table = [[searchResultsTable alloc] init];
    [table searchBarSearchButtonClicked:self.searchController.searchBar];
}

-(void)viewPostDetail:(FeedPost *)post {
    FeedPostDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FeedPostDetailViewController"];
    //vc.feedPost = post;
    vc.dict = [post toDictionary];
    Path *path = [[Path alloc] initWithDictionary:post.reference];
    vc.path = path;
    //[vc zoomToPath:path];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - scroll view delegate methods


@end
