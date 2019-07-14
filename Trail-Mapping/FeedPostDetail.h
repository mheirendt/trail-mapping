//
//  FeedPostDetail.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/6/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
#import "Post.h"
#import "Path.h"
#import "FriendsView.h"
#import "Comment.h"
@protocol MHCommentDelegate;
@class FeedPost;
@interface FeedPostDetail : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, UITextViewDelegate, MHCommentDelegate>

@property (strong, nonatomic) UIView *commentToolbar;
@property (nonatomic, retain) UITextView *chatBox;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, retain) NSMutableDictionary *dict;
@property (strong, retain) Path *path;
@property (strong, retain) Post *post;
@property (weak, nonatomic) UIView *mapContainer;
@property NSInteger textFieldPreviousHeight;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) FriendsView *friendsView;
@property bool isCommenting;
@property bool isReplying;
@property (strong, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) NSString *lastSeen;

-(void) zoomToPath:(Path *)path;

@end
