//
//  SigninScene.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/7/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "SigninScene.h"

@interface SigninScene ()

@end

@implementation SigninScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissView:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signin"];
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchToRegister:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"register" forKey:@"signin"];
    [self dismissViewControllerAnimated:NO completion:nil];
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
