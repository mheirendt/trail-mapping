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
    self.mapView.delegate = self;
    [self startLocationManager];
    self.allLocations = [[NSMutableArray alloc] init];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(placePin:)];
    press.minimumPressDuration = .5f;
    [self.mapView addGestureRecognizer:press];
}
#pragma mark - Location services
- (void)startLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization]; // Add This Line
    locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
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
    [self drawLine];
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


- (void)drawLine {
    
    // remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    //NSLog(@"Starting");
    CLLocationCoordinate2D coordinates[self.allLocations.count];
    //NSLog(@"locationCount: %lul", (unsigned long)self.allLocations.count);
    int i = 0;
    for (Annotation *currentPin in self.allLocations) {
        coordinates[i] = currentPin.coordinate;
        NSLog(@"Coordinates: %f, %f", coordinates[i].latitude, coordinates[i].longitude);
        i++;
    }
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.allLocations.count];
    self.polyline = polyline;
    // create an MKPolylineView and add it to the map view
    //self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    //self.lineView = [[MKPolylineRenderer alloc] initWithPolyline:self.polyline];;
    //self.lineView.fillColor = [UIColor redColor];
    //self.lineView.lineWidth = 5;
    [self.mapView addOverlay:polyline];
    
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    //self.overlayView = [[MKOverlayView alloc] initWithFrame:self.mapView.frame];
    self.lineView =[[MKPolylineRenderer alloc] initWithPolyline:overlay];
    self.lineView.strokeColor = [UIColor orangeColor];
    self.lineView.lineWidth = 3.0;
    return self.lineView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
