//
//  AppDelegate.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Path.h"
#import "Paths.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *trails;
@property (strong, nonatomic) UIImage *overviewImage;
@property (strong, nonatomic) Path *submittedPath;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSString *deselection;

@property (strong, nonatomic) Paths* paths;

@end

