//
//  trailOverviewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/30/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "trailOverviewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface trailOverviewController ()

@end

@implementation trailOverviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameTextBox.delegate = self;
    [self.submitForm addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    //AppDelegate *del = [[UIApplication sharedApplication] delegate];
    //[self.imageView setImage:del.overviewImage];
    //CGRect frame = CGRectMake(self.view.frame.size.width/2, 20, 300, 250);
    //[self.imageView setFrame:frame];
    //self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}
-(void)dismissKeyboard {
    [self.nameTextBox resignFirstResponder];
}
-(void)dismiss{
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)submit{
    //AppDelegate *del = [[UIApplication sharedApplication] delegate];
    //MKPolyline *polyline = [del.trails lastObject];
    //polyline.title = self.nameTextBox.text;
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
    vc.submitFlag = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length >= 2){
        self.submitForm.enabled = true;
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.nameTextBox resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
