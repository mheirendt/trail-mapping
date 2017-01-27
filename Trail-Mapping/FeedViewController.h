//
//  FeedViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/13/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedPost.h"
#import "searchResultsTable.h"

////TODO
@class FeedPost;

@interface FeedViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UISearchControllerDelegate>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *posts;

-(void)updateFeed:(UIRefreshControl *)refreshControl;
-(IBAction)viewProfile:(id)sender;
-(void)viewPostDetail:(FeedPost *)post;
@end
