//
//  ProfileViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 11/23/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *joined;
@property (weak, nonatomic) IBOutlet UILabel *following;
@property (weak, nonatomic) IBOutlet UILabel *followers;

@property (strong, nonatomic) NSMutableArray *peopleFollowing;
@property (strong, nonatomic) NSMutableArray *peopleFollowers;

@end
