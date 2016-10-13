//
//  categoryView.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/20/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "categoryView.h"
#import "CategoryCell.h"
#import "AppDelegate.h"

@implementation categoryView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    self.categories = [NSMutableArray array];
    _categoryTable = [[UITableView alloc] initWithFrame:rect];
    _categoryTable.delegate = self;
    _categoryTable.dataSource = self;
    _categoryTable.scrollEnabled = NO;
    [self addSubview:_categoryTable];
    
    //Okay Button
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setFrame:CGRectMake(0, 0, 70, 70)];
    [self.button addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.button setImage:[UIImage imageNamed:@"Complete"] forState:UIControlStateNormal];
    [self addSubview:self.button];
    CGRect bounds = self.button.superview.bounds;
    self.button.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + 150);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell == nil) {

        [tableView registerNib:[UINib nibWithNibName:@"tableCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifier"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    }
    if (indexPath.row == 0){
        cell.image.image = [UIImage imageNamed:@"Run"];
    }
    if (indexPath.row == 1){
        cell.image.image = [UIImage imageNamed:@"Bike"];
    }
    if (indexPath.row == 2){
        cell.image.image = [UIImage imageNamed:@"Skate"];
    }
    if (indexPath.row == 3){
        cell.image.image = [UIImage imageNamed:@"Handicap"];
    }

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CategoryCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //Row 1
    if (indexPath.row == 0){
        if (!_zeroSelected){
            del.categories = _categories;
            [self.categories addObject:[NSString stringWithFormat:@"Run"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Selection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Run Invert"];
            cell.backgroundColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
            _zeroSelected = YES;
        } else {
            NSUInteger index = [self.categories indexOfObject: @"Run"];
            del.categories = _categories;
            [self.categories removeObjectAtIndex:index];
            del.deselection = @"Run";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Deselection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Run"];
            cell.backgroundColor = [UIColor whiteColor];
            _zeroSelected = NO;
        }
    }
    //Row 2
    if (indexPath.row == 1){
        if (!_oneSelected){
            del.categories = _categories;
            [self.categories addObject:[NSString stringWithFormat:@"Bike"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Selection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Bike Invert"];
            cell.backgroundColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
            _oneSelected = YES;
        } else {
            NSUInteger index = [self.categories indexOfObject: @"Bike"];
            del.categories = _categories;
            [self.categories removeObjectAtIndex:index];
            del.deselection = @"Bike";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Deselection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Bike"];
            cell.backgroundColor = [UIColor whiteColor];
            _oneSelected = NO;
        }
    }
    //Row 3
    if (indexPath.row == 2){
        if (!_twoSelected){
            del.categories = _categories;
            [self.categories addObject:[NSString stringWithFormat:@"Skate"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Selection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Skate Invert"];
            cell.backgroundColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
            _twoSelected = YES;
        } else {
            del.categories = _categories;
            NSUInteger index = [self.categories indexOfObject: @"Skate"];
            del.deselection = @"Skate";
            [self.categories removeObjectAtIndex:index];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Deselection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Skate"];
            cell.backgroundColor = [UIColor whiteColor];
            _twoSelected = NO;
        }
    }
    //Row 4
    if (indexPath.row == 3){
        if (!_threeSelected){
            del.categories = _categories;
            [self.categories addObject:[NSString stringWithFormat:@"Handicap"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Selection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Handicap Invert"];
            cell.backgroundColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
            _threeSelected = YES;
        } else {
            del.categories = _categories;
            NSUInteger index = [self.categories indexOfObject: @"Handicap"];
            [self.categories removeObjectAtIndex:index];
            del.deselection = @"Handicap";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Deselection" object:nil];
            cell.image.image = [UIImage imageNamed:@"Handicap"];
            cell.backgroundColor = [UIColor whiteColor];
            _threeSelected = NO;
        }
    }
}
-(void)dismissView{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"categoriesDismissed" object:nil]];
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    del.categories = self.categories;
    
}
@end
