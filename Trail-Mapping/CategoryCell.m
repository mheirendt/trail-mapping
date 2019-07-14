//
//  CategoryCell.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/20/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell
@synthesize image;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //UIView *view = [[UIView alloc] initWithFrame:self.frame];
    //view.backgroundColor = [UIColor whiteColor];
    //self.selectedBackgroundView = view;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
