//
//  ViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//
@import MapKit;
#import <UIKit/UIKit.h>
#import "Annotation.h"
#import "Path.h"
#import "Vertex.h"
#import "subView.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *traceButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *completeSketch;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomToButton;

@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *allLocations;
@property  Path *result;
@property (nonatomic, strong) NSTimer *timer;
@property int seconds;
@property float distance;
@property float elevation;
@property (retain, nonatomic) MKPolylineRenderer *lineView;
@property BOOL tracing;
@property subView *submissionView;
@property BOOL submitFlag;
@property int following;
@property (strong, nonatomic) NSMutableArray *vertices;
@property (strong, nonatomic) NSMutableArray *movedCoordinates;

#pragma mark - Hide and show the tab bar
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion;
- (BOOL)tabBarIsVisible;
@end

