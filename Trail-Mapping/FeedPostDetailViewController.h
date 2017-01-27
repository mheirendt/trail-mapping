//
//  FeedPostDetailViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/4/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//
@import MapKit;
#import <UIKit/UIKit.h>
#import "FeedPost.h"
#import "Path.h"
//TODO: Find missing file
@class FeedPost;

@interface FeedPostDetailViewController : UIViewController <MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *feedView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, retain) NSMutableDictionary *dict;
@property (strong, retain) Path *path;
@property (strong, retain) FeedPost *post;


-(void) zoomToPath:(Path *)path;
@end
