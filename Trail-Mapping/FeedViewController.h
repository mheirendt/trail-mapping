//
//  FeedViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 10/13/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedPost.h"

@interface FeedViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *posts;

-(void)updateFeed;
@end
