//
//  ViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocationManager];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.allLocations = [[NSMutableArray alloc] init];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(placePin:)];
    press.minimumPressDuration = .5f;
    [self.mapView addGestureRecognizer:press];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    press.minimumPressDuration = .5f;
    [self.mapView addGestureRecognizer:tap];
}
#pragma mark - Location services
- (void)startLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization]; // Add This Line
    locationManager.distanceFilter = 2; //whenever we move
    self.locationManager.activityType = CLActivityTypeFitness;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}
-(void)placePin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchCoord = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    //CLLocationCoordinate2D offset = CLLocationCoordinate2DMake(touchCoord.latitude - .0005,touchCoord.longitude);
    id anno = [Annotation initWithCoordinate:touchCoord identifier:@"Submission"];
    [self.mapView addAnnotation:anno];
    [self.allLocations addObject:anno];
    //[self drawLine];
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(offset, 100, 100);
    //[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    //[self pointDropped:touchCoord];
    /*
     for (id annotation in self.mapView.annotations)
     {
     if ([[annotation title] isEqualToString:@"Submission"])
     [self.mapView removeAnnotation:annotation];
     }
     */
}
- (IBAction)tracePath:(id)sender {
    self.seconds = 0;
    self.distance = 0;
    self.allLocations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(eachSecond) userInfo:nil repeats:YES];
    [self.locationManager startUpdatingLocation];
    // remove polyline if one exists
    //[self.mapView removeOverlay:self.traceLine];
    
    // create an array of coordinates from allPins
    _tracing = YES;
    //CLLocationCoordinate2D coordinates[self.allLocations.count];
    //int i = 0;
    //for (CLLocationCoordinate2D *currentPin in self.allLocations) {
        //coordinates[i] = currentPin.coordinate;
        //NSLog(@"Coordinates: %f, %f", coordinates[i].latitude, coordinates[i].longitude);
        //i++;
    //}
    
    // create a traceLine with all cooridnates

}
- (IBAction)stopTracing:(id)sender {
    _tracing = NO;
    [self.locationManager stopUpdatingLocation];
    [self.mapView addOverlay:[self polyLine]];
}
- (void)eachSecond
{
    self.seconds++;
    //self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    //self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    //self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_tracing){
        
        for (CLLocation *newLocation in locations) {
            if (newLocation.horizontalAccuracy < 20) {
                
                // update distance
                if (self.allLocations.count > 0) {
                    self.distance += [newLocation distanceFromLocation:self.allLocations.lastObject];
                }
                
                [self.allLocations addObject:newLocation];
            }
        }
    }
}
- (MKPolyline *)polyLine {
    NSLog(@"Creating polyling");
    CLLocationCoordinate2D coords[self.allLocations.count];
    
    for (int i = 0; i < self.allLocations.count; i++) {
        CLLocation *location = [self.allLocations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    }
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coords count:self.allLocations.count];
    poly.title = @"Trail";
    return poly;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    self.lineView =[[MKPolylineRenderer alloc] initWithPolyline:overlay];
    self.lineView.strokeColor = [UIColor orangeColor];
    self.lineView.lineWidth = 3.0;
    return self.lineView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
