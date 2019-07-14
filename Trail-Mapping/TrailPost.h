//
//  TrailPost.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/7/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "Post.h"
#import "AppDelegate.h"/*
#import "FeedViewController.h"
#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "FeedPostDetail.h"
#import "User.h"
#import "Path.h"*/

@interface TrailPost : Post <UIGestureRecognizerDelegate>

@property (strong, retain) IBOutlet UIImageView *imageCenter;
@property (strong, retain) IBOutlet UIImageView *imageLeft1;
@property (strong, retain) IBOutlet UIImageView *imageLeft2;
@property (strong, retain) IBOutlet UIImageView *imageRight1;
@property (strong, retain) IBOutlet UIImageView *imageRight2;
@property (strong, retain) IBOutlet UILabel *tagsLabel;

//Model
@property (retain, strong) NSDictionary* reference;
@property (retain, strong) NSString* body;

//@property (retain, strong) Path *path;

- (NSDictionary*) toDictionary;
//- (void) persist:(FeedPost*)post;

@end
