//
//  categoryView.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/20/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface categoryView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *categoryTable;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) NSMutableArray *categories;
@property BOOL zeroSelected;
@property BOOL oneSelected;
@property BOOL twoSelected;
@property BOOL threeSelected;

@end
