//
//  ProfileViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peopleFollowers = [[NSMutableArray alloc] init];
    self.peopleFollowing = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)viewFollowing:(id)sender {
    NSLog(@"following");
}
- (IBAction)viewFollowers:(id)sender {
    NSLog(@"Followers");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
