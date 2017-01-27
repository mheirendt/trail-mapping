//
//  FriendsViewCell.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/15/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UIView *followingView;
@property (weak, nonatomic) IBOutlet UIView *followView;


@end
