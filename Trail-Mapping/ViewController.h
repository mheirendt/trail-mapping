//
//  ViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
#import "Annotation.h"
#import "AttributedPolyline.h"
#import "subView.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *traceButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *completeSketch;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomToButton;

@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *allLocations;
@property (strong, nonatomic) MKPolyline *result;
@property (nonatomic, strong) NSTimer *timer;
@property int seconds;
@property float distance;
@property float elevation;
@property (retain, nonatomic) AttributedPolyline *traceLine;
@property (retain, nonatomic) MKPolylineRenderer *lineView;
@property BOOL tracing;
@property subView *submissionView;
@property BOOL submitFlag;
@property int following;
@property (strong, nonatomic) NSMutableArray *vertices;
@property (strong, nonatomic) NSMutableArray *movedCoordinates;

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion;
- (BOOL)tabBarIsVisible;
@end

