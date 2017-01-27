//
//  searchResultsTable.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/11/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ProfileViewController.h"
#import "FeedViewController.h"
#import "FriendsViewCell.h"

@interface searchResultsTable : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSMutableArray* results;
@property bool followingFlag;

@end
