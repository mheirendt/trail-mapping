//
//  overviewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/29/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "overviewController.h"
#import "AppDelegate.h"

@interface overviewController ()

@end

@implementation overviewController
@synthesize locationManager;
@class overviewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocationManager];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.tabBarController.delegate = self;
    //self.allLocations = [[NSMutableArray alloc] init];
    //[self.traceButton addTarget:self action:@selector(tracePath) forControlEvents:UIControlEventTouchUpInside];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    // Do any additional setup after loading the view, typically from a nib.

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    //press.minimumPressDuration = .5f;
    [self.mapView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (void)startLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization]; // Add This Line
    locationManager.distanceFilter = 2; //whenever we move
    self.locationManager.activityType = CLActivityTypeFitness;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    if ([viewController isKindOfClass:[overviewController class]]){
        NSLog(@"switching");
        AppDelegate *del = [[UIApplication sharedApplication] delegate];
        if (del.trails){
            NSLog(@"delTrails: %@", del.trails);
            [self.mapView addOverlays:del.trails];
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    self.lineView =[[MKPolylineRenderer alloc] initWithPolyline:overlay];
    self.lineView.strokeColor = [UIColor orangeColor];
    self.lineView.lineWidth = 3.0;
    return self.lineView;
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

#pragma mark - handling taps on the overlay
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly
{
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
        MKMapPoint ptB = poly.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint ptClosest;
        if (u < 0.0) {
            
            ptClosest = ptA;
        }
        else if (u > 1.0) {
            
            ptClosest = ptB;
        }
        else {
            
            ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
    }
    
    return distance;
}


/** Converts |px| to meters at location |pt| */
- (double)metersFromPixel:(NSUInteger)px atPoint:(CGPoint)pt
{
    CGPoint ptB = CGPointMake(pt.x + px, pt.y);
    
    CLLocationCoordinate2D coordA = [self.mapView convertPoint:pt toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D coordB = [self.mapView convertPoint:ptB toCoordinateFromView:self.mapView];
    
    return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB));
}


#define MAX_DISTANCE_PX 22.0f
- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if ((tap.state & UIGestureRecognizerStateRecognized) == UIGestureRecognizerStateRecognized) {
        
        // Get map coordinate from touch point
        CGPoint touchPt = [tap locationInView:self.mapView];
        CLLocationCoordinate2D coord = [self.mapView convertPoint:touchPt toCoordinateFromView:self.mapView];
        
        double maxMeters = [self metersFromPixel:MAX_DISTANCE_PX atPoint:touchPt];
        
        float nearestDistance = MAXFLOAT;
        MKPolyline *nearestPoly = nil;
        
        // for every overlay ...
        for (id <MKOverlay> overlay in self.mapView.overlays) {
            
            // .. if MKPolyline ...
            if ([overlay isKindOfClass:[MKPolyline class]]) {
                
                // ... get the distance ...
                float distance = [self distanceOfPoint:MKMapPointForCoordinate(coord)
                                                toPoly:overlay];
                
                // ... and find the nearest one
                if (distance < nearestDistance) {
                    
                    nearestDistance = distance;
                    nearestPoly = overlay;
                }
            }
        }
        
        if (nearestDistance <= maxMeters) {
            
            NSLog(@"Touched poly: %@\n"
                  "    distance: %f", nearestPoly.title, nearestDistance);
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    
}*/


@end
