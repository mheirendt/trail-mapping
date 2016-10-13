//
//  SettingsTable.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsCell.h"
#import "categoryView.h"

@interface SettingsTable : UITableViewController

@property (strong, nonatomic)UIView *backgroundView;
@property (strong, nonatomic)categoryView *categoriesSelector;

@end
