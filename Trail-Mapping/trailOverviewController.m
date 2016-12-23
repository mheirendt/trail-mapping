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
#import "overviewController.h"
#import "Path.h"

@interface trailOverviewController ()

@end

@implementation trailOverviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.path = del.submittedPath;
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    [self.tokenField.textField becomeFirstResponder];
    self.tokenField.textField.returnKeyType = UIReturnKeyNext;
    self.tokens = [NSMutableArray array];
    self.tokenField.textField.textColor = [UIColor whiteColor];
    self.tokenField.textField.placeholder = @"Enter tag name and press return";
    [self.tokenField reloadData];
}
-(void)dismiss{
    self.submitFlag = 1;
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.submitFlag = 1;
}

- (IBAction)sendButtonPressed:(id)sender
{
    _submitFlag = 1;
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Path *path = del.submittedPath;
    path.categories = del.categories;
    path.tags = self.tokens;
    //path.submittedUser = [NSNumber numberWithInt:3];
    
    //NSDictionary *dict = [path toDictionary];
    Paths *paths = [[Paths alloc] init];
    [paths persist:path];
    //NSLog(@"%@", dict);
    //NSLog(@"Count: %lu", (unsigned long)[path.vertices count]);
    //NSLog(@"ID: %@, userID: %@, categories: %@, tags: %@ polyline: %f, %f", path._id, path.userID, path.categories, path.tags, [path.polyline coordinate].latitude, [path.polyline coordinate].longitude);
    
    [self.tokenField.textField resignFirstResponder];
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
        overviewController *ovc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"overviewController"];
    vc.submitFlag = YES;
    [ovc modelUpdated];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)tokenDeleteButtonPressed:(UIButton *)tokenButton
{
    NSUInteger index = [self.tokenField indexOfTokenView:tokenButton.superview];
    if (index != NSNotFound) {
        [self.tokens removeObjectAtIndex:index];
        [self.tokenField reloadData];
        if ([self.tokens count] == 0){
            self.submitForm.enabled = NO;
        } else {
            self.submitForm.enabled = YES;
        }
    }
}


#pragma mark - ZFTokenField DataSource
- (CGFloat)lineHeightForTokenInField:(ZFTokenField *)tokenField
{
    return 38;
}

- (NSUInteger)numberOfTokenInField:(ZFTokenField *)tokenField
{
    return self.tokens.count;
}

- (UIView *)tokenField:(ZFTokenField *)tokenField viewForTokenAtIndex:(NSUInteger)index
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"TokenView" owner:nil options:nil];
    UIView *view = nibContents[0];
    UILabel *label = (UILabel *)[view viewWithTag:2];
    UIButton *button = (UIButton *)[view viewWithTag:3];
    
    [button addTarget:self action:@selector(tokenDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    label.text = self.tokens[index];
    CGSize size = [label sizeThatFits:CGSizeMake(1000, 40)];
    view.frame = CGRectMake(0, 0, size.width + 97, 40);
    return view;
}

#pragma mark - ZFTokenField Delegate
- (CGFloat)tokenMarginInTokenInField:(ZFTokenField *)tokenField
{
    return 5;
}

- (void)tokenField:(ZFTokenField *)tokenField didReturnWithText:(NSString *)text
{
    if (tokenField.textField.text.length > 0) {
        if ([self.tokens count] <= 8){
            [self.tokens addObject:text];
            [tokenField reloadData];
            if ([self.tokens count] >= 1){
                self.submitForm.enabled = YES;
            }
        } else {
            [self showErrorMessage:@"You have met the limit of allowed tags."];
        }
    } else {
        [self showErrorMessage:@"You must enter a tag name."];
    }
}
-(void)showErrorMessage:(NSString *)message{
    [self.warningMessage setAlpha:0.0f];
    self.warningMessage.text = message;
    
    //fade in
    [UIView animateWithDuration:.7f animations:^{
        
        [self.warningMessage setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        
        //fade out
        [UIView animateWithDuration:1.f delay:1.5f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            [self.warningMessage setAlpha:0.0f];
        } completion:nil];
    }];
}
-(void)tokenFieldDidBeginEditing:(ZFTokenField *)tokenField{
    
}

- (void)tokenField:(ZFTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
    [self.tokens removeObjectAtIndex:index];
    if ([self.tokens count] == 0){
        self.submitForm.enabled = NO;
    } else {
        self.submitForm.enabled = YES;
    }
}

- (BOOL)tokenFieldShouldEndEditing:(ZFTokenField *)textField
{
    if(_submitFlag == 1){
        return YES;
    }else{
        return NO;
    }
}



@end
