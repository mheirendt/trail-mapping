//
//  SettingsTable.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "SettingsTable.h"

@interface SettingsTable ()

@end

@implementation SettingsTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCategoryView) name:@"categoriesDismissed" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settings"];
    if (cell == nil) {
        
        [tableView registerNib:[UINib nibWithNibName:@"SettingsTableCell" bundle:nil] forCellReuseIdentifier:@"settings"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"settings"];
    }

   if (indexPath.row == 0){
       cell.headerText.text = @"Default Categories";
       cell.subText.text = @"Click the button to select default categories for your paths.";
       [cell.button setTitle:@"Select Categories" forState:UIControlStateNormal];
       [cell.button addTarget:self action:@selector(showCategoryTable) forControlEvents:UIControlEventTouchUpInside];
       cell.button.hidden = NO;
       cell.switchButton.hidden = YES;
   }
    if (indexPath.row == 1){
        cell.headerText.text = @"Default Categories";
        cell.subText.text = @"Click the button to select default categories for your paths.";
        [cell.button setTitle:@"Select Categories" forState:UIControlStateNormal];
        cell.button.hidden = NO;
        cell.switchButton.hidden = YES;
    }
    if (indexPath.row == 2){
        cell.headerText.text = @"Default Categories";
        cell.subText.text = @"Click the button to select default categories for your paths.";
        [cell.button setTitle:@"Select Categories" forState:UIControlStateNormal];
        cell.button.hidden = NO;
        cell.switchButton.hidden = YES;
    }
    if (indexPath.row == 3){
        cell.headerText.text = @"Default Categories";
        cell.subText.text = @"Click the button to select default categories for your paths.";
        [cell.button setTitle:@"Select Categories" forState:UIControlStateNormal];
        cell.button.hidden = NO;
        cell.switchButton.hidden = YES;
    }
    
    return cell;
}
-(void)showCategoryTable{
    _backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = .5f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCategoryView)];
    [_backgroundView addGestureRecognizer:recognizer];
    [self.view addSubview:_backgroundView];
    if (!_categoriesSelector){
        _categoriesSelector = [[categoryView alloc] initWithFrame:CGRectMake(0, 0, 250, 375)];
        _categoriesSelector.backgroundColor = [UIColor whiteColor];
        CGRect viewBounds = self.view.bounds;
        _categoriesSelector.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds) - 70);
        _categoriesSelector.layer.borderWidth = 1.5f;
        _categoriesSelector.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    }
    [self.view addSubview:_categoriesSelector];
}
-(void)dismissCategoryView{
    [self.categoriesSelector removeFromSuperview];
    [UIView animateWithDuration:0.5 delay:0.f options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 0;
    }
                     completion:^(BOOL finished){
                         [self.backgroundView removeFromSuperview];
                     }];
    
}

@end
