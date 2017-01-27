//
//  introScene.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/9/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "introScene.h"

@interface introScene ()

@end

@implementation introScene

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self setTabBarVisible:NO animated:NO completion:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

}
- (IBAction)showRegisterScene:(id)sender {
    UIViewController *registerScene = [self.storyboard instantiateViewControllerWithIdentifier:@"register"];
    [self.navigationController pushViewController:registerScene animated:YES];
}
- (IBAction)showLoginScene:(id)sender {
    UIViewController *loginScene = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self.navigationController pushViewController:loginScene animated:YES];
}

#pragma mark - Hide and show the tab bar
// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

@end
