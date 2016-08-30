//
//  ViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

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
    [self.traceButton addTarget:self action:@selector(tracePath) forControlEvents:UIControlEventTouchUpInside];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(placePin:)];
    press.minimumPressDuration = .5f;
    [self.mapView addGestureRecognizer:press];
    press.minimumPressDuration = .5f;
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
- (void)tracePath {
    self.cancelButton.hidden = NO;
    self.seconds = 0;
    self.distance = 0;
    self.allLocations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(eachSecond) userInfo:nil repeats:YES];
    [self.locationManager startUpdatingLocation];
    [self.traceButton addTarget:self action:@selector(stopTracing) forControlEvents:UIControlEventTouchUpInside];
    [self.traceButton setImage:[UIImage imageNamed:@"Complete"] forState:UIControlStateNormal];
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

- (void)stopTracing {
    _tracing = NO;
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSLog(@"locs: %@", self.allLocations);
        if(overlay){
            [delegate.trails addObject:overlay];
            NSLog(@"del: %@", delegate.trails);
        }
        [self.mapView removeOverlay:overlay];
    }
    self.cancelButton.hidden = YES;
    //[self.mapView addOverlay:[self polyLine]];
    [self.traceButton addTarget:self action:@selector(tracePath) forControlEvents:UIControlEventTouchUpInside];
    [self.traceButton setImage:[UIImage imageNamed:@"Trace"] forState:UIControlStateNormal];
    [self.locationManager stopUpdatingLocation];
    //[self showSubview];
}
- (IBAction)cancelTracing:(id)sender {
    _tracing = NO;
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    self.cancelButton.hidden = YES;
    [self.locationManager stopUpdatingLocation];
    [self.traceButton addTarget:self action:@selector(tracePath) forControlEvents:UIControlEventTouchUpInside];
    [self.traceButton setImage:[UIImage imageNamed:@"Trace"] forState:UIControlStateNormal];
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
            
            NSDate *eventDate = newLocation.timestamp;
            
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
            
            if (howRecent < 1.0/* && newLocation.horizontalAccuracy < 5*/) {
                NSLog(@"logging");
                // update distance
                if (self.allLocations.count > 0) {
                    self.distance += [newLocation distanceFromLocation:self.allLocations.lastObject];
                    CLLocationCoordinate2D coords[2];
                    coords[0] = ((CLLocation *)self.allLocations.lastObject).coordinate;
                    coords[1] = newLocation.coordinate;
                    
                    //MKCoordinateRegion region =
                    //MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                    //[self.mapView setRegion:region animated:YES];
                    
                    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                }
                NSLog(@"locs2: %@", self.allLocations);
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
    //[self showSubview];
    return poly;
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

-(void)showSubview{
    if (!self.submissionView){
        self.submissionView = [[subView alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height-110, self.view.bounds.size.width-20, self.view.bounds.size.height)];
    }
    //self.submissionView.coordinates = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    [self.view addSubview:self.submissionView];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.submissionView.bounds];
    self.submissionView.layer.shadowPath = path.CGPath;
    CGRect frame = CGRectMake(10, (self.view.bounds.size.height/2)-110, self.view.bounds.size.width-20, (self.view.bounds.size.height/2)+110);
    [UIView animateWithDuration:0.5f animations:^{
        self.submissionView.frame = frame;
    } completion:^(BOOL finished) {
        if(finished){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"viewDismissed" object:self];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - show overview on complete
- (void)loadMap
{
    if (self.allLocations.count > 0) {
        
        self.mapView.hidden = NO;
        
        // set the map bounds
        //[self.mapView setRegion:[self mapRegion]];
        
        // make the line(s!) on the map
        [self.mapView addOverlay:[self polyLine]];
        
    } /*else {
        
        // no locations were found!
        self.mapView.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Sorry, this run has no locations saved."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
       */
}



@end
