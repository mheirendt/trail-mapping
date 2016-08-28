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

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *allLocations;
@property (nonatomic, strong) NSMutableArray *coordinates;
@property (retain, nonatomic) MKPolyline *polyline;
@property (retain, nonatomic) MKPolylineRenderer *lineView;
@property (retain, nonatomic) MKOverlayView *overlayView;

-(void)placePin:(UIGestureRecognizer *)gestureRecognizer;
@end

