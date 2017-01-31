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
#import "FriendsView.h"
//TODO: Find missing file
@class FeedPost;

@interface FeedPostDetailViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIView *commentToolbar;
@property (nonatomic, retain) UITextView *chatBox;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, retain) NSMutableDictionary *dict;
@property (strong, retain) Path *path;
@property (strong, retain) FeedPost *post;
@property (weak, nonatomic) UIView *mapContainer;
@property (strong, nonatomic) NSString* isCommenting;
@property NSInteger textFieldPreviousHeight;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) FriendsView *friendsView;

-(void) zoomToPath:(Path *)path;
@end
