//
//  FeedViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/13/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedPostDetail.h"
#import "Post.h"
#import "searchResultsTable.h"
#import "FriendsView.h"
#import "ErrorView.h"

////TODO
@class FeedPost;

@interface FeedViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UISearchControllerDelegate, MHPostDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSString *lastSeen;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) FriendsView *friendsView;

-(void)updateFeed:(UIRefreshControl *)refreshControl;
-(IBAction)viewProfile:(id)sender;

-(void)dismissFriendsView:(NSNotification *)notification;
@end
