//
//  searchResultsTable.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/11/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "searchResultsTable.h"

@interface searchResultsTable ()

@end

@implementation searchResultsTable

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _results = [[NSMutableArray alloc] init];
}
-(void)viewWillDisappear:(BOOL)animated {
    _results = nil;
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

-(void)showFollowing {
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i)
    {
        FriendsViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSString *cellUserId = cell.user._id;
        AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        for (int s = 0; s < [del.activeUser.following count]; s++) {
            NSString *followingId = [del.activeUser.following[s] objectForKey:@"_id"];
            if ([followingId isEqualToString:cellUserId]) {
                cell.followingLabel.text = @"Following";
                [cell.followingView.layer setBackgroundColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _results.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {
        
        [tableView registerNib:[UINib nibWithNibName:@"FriendsViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    }
    UITapGestureRecognizer *follow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(follow:)];
    [cell.followingView addGestureRecognizer:follow];
    User* user = [[User alloc] initWithDictionary:[_results objectAtIndex:indexPath.row]];
    cell.user = user;
    cell.usernameLabel.text = user.username;

    if (user.avatar) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:user.avatar];
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
            if ( data == nil )
            return;
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.avatar.image = [UIImage imageWithData:data];
            });
        });
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [[User alloc] initWithDictionary:[_results objectAtIndex:indexPath.row]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"profile"];
    vc.user = user;
    //vc.navigationItem.titleView = [[UISearchController alloc] init].searchBar;
    vc.isViewingOtherProfile = true;
    [self.presentingViewController.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UISearchController delegate methods
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    id block = ^{
        NSString* base = @"https://secure-garden-50529.herokuapp.com/user/search/usernames/";
        NSString* urlstr = [base stringByAppendingString:searchBar.text];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    _results = [[NSMutableArray alloc] initWithArray:arr];
                    [self.tableView reloadData];
                    [self.tableView setNeedsDisplay];
                    [self showFollowing];
                });
            }
        }];
        [dataTask resume];
        [self.tableView reloadData];
        [self.tableView setNeedsDisplay];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

- (void)follow:(UITapGestureRecognizer *) recognizer {
    CGPoint point = [recognizer locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
    FriendsViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //NSString *username = cell.usernameLabel.text;
    NSString *userId = cell.user._id;
    id block = ^{
        NSURL* url;
        if ([cell.followingLabel.text isEqualToString:@"Follow"]) {
            url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/follow/userId"];
        } else {
            url = [NSURL URLWithString:@"https://secure-garden-50529.herokuapp.com/user/unfollow/userId"];
        }
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
        request.HTTPMethod = @"POST";
        [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userId, @"userId", nil];
        NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
        request.HTTPBody = data;
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                del.activeUser = [[User alloc] initWithDictionary:dict];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"searchControllerRefresh" object:nil]];
                if ([cell.followingLabel.text isEqualToString:@"Following"]) {
                    [cell.followingView.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
                    cell.followingLabel.text = @"Follow";
                } else {
                    [cell.followingView.layer setBackgroundColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
                    cell.followingLabel.text = @"Following";
                }
            });
        }];
        [dataTask resume];
    };
    //Create a Grand Central Dispatch queue and run the operation async
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

@end
