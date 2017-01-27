//
//  FriendsViewCell.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/15/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "FriendsViewCell.h"

@implementation FriendsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //19 80 80
    [_avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
    [_followView setUserInteractionEnabled:YES];
    [_followingView setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
