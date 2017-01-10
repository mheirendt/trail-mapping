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
#import "FeedPost.h"
#import "User.h"

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
    //Save the path
    _submitFlag = 1;
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Path *path = del.submittedPath;
    path.categories = del.categories;
    path.tags = self.tokens;
    Paths *paths = [[Paths alloc] init];
    [paths persist:path];
    [self.tokenField.textField resignFirstResponder];
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewController"];
    overviewController *ovc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"overviewController"];
    vc.submitFlag = YES;
    [ovc modelUpdated];
    [self dismissViewControllerAnimated:NO completion:nil];
    /*
    //Query active user
    NSString* urlstr = [NSString stringWithFormat:@"https://secure-garden-50529.herokuapp.com/user/search/username/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    NSURL* url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *error) {
        if (error){
            NSLog(@"error: %@", [error localizedDescription]);
        } else {
            
            //submit the trail
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            User *currUser = [[User alloc] initWithDictionary:dict];
            
            
            //post
            //NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            NSMutableDictionary *content = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"created a trail /n lkjdakljflda /n lfjadklsfkda /n kldflkadj /n ldjkfajldf /n   jlkafljdkjfa /n   ldkjfakldfda /n   fkdlaldjf /n  kjfaldfjdakfd /n dlkjfkadjfdka /n", @"body", nil];
            [content setObject: currUser.username forKey:@"submittedUsername"];
            [content setObject:currUser._id forKey:@"submittedUser"];
            //[content setObject:@"Jun 13, 2012 12:00:00 AM" forKey:@"created"];
            [content setObject:@"4" forKey:@"likes"];
            [content setObject:@"300" forKey:@"comments"];
            FeedPost *post = [[FeedPost alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 220)];
            [post setDictionary:content];
            [post persist:post];
            
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    [dataTask resume];
     */
    
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
