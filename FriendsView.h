//
//  FriendsView.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/15/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "FriendsViewCell.h"

@interface FriendsView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) UITableView *userTable;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) NSMutableArray *users;

@end
