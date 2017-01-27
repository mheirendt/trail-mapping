//
//  ProfileViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "FriendsView.h"

@interface ProfileViewController : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *joined;
@property (strong, nonatomic) IBOutlet UILabel *following;
@property (strong, nonatomic) IBOutlet UILabel *followers;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) FriendsView *friendsView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *image;

@property bool isViewingOtherProfile;

@property (strong, nonatomic) User *user;


@property (strong, nonatomic) NSMutableArray *peopleFollowing;
@property (strong, nonatomic) NSMutableArray *peopleFollowers;


@end
