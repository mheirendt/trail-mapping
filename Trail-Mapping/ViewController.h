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
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDate *lastTimestamp;
@property (nonatomic, strong) NSMutableArray *allLocations;
@property (nonatomic, strong) NSMutableArray *coordinates;
@property (nonatomic, strong) NSTimer *timer;
@property int seconds;
@property float distance;
@property float elevation;
@property (retain, nonatomic) AttributedPolyline *traceLine;
@property (retain, nonatomic) MKPolylineRenderer *lineView;
@property BOOL tracing;
@property subView *submissionView;

-(void)placePin:(UIGestureRecognizer *)gestureRecognizer;
@end

