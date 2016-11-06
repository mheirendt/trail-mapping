//
//  overviewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/29/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "overviewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface overviewController ()

@end

@implementation overviewController
@synthesize locationManager;
@class overviewController;
@class ViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startLocationManager];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.tabBarController.delegate = self;
    
    [self paths].delegate = self;
    //self.allLocations = [[NSMutableArray alloc] init];
    //[self.traceButton addTarget:self action:@selector(tracePath) forControlEvents:UIControlEventTouchUpInside];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    // Do any additional setup after loading the view, typically from a nib.

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    //press.minimumPressDuration = .5f;
    [self.mapView addGestureRecognizer:tap];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self modelUpdated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *flag = [[NSUserDefaults standardUserDefaults] objectForKey:@"signin"];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if ([flag isEqualToString:@"signin"]){
        UIViewController *registerScene = [self.storyboard instantiateViewControllerWithIdentifier:@"register"];
        [self presentViewController:registerScene animated:NO completion:nil];
    }
    if ([flag isEqualToString:@"register"]){
        UIViewController *registerScene = [self.storyboard instantiateViewControllerWithIdentifier:@"register"];
        [self presentViewController:registerScene animated:NO completion:nil];
    }
    if (name == nil || [name isEqualToString:@""]) {
        self.definesPresentationContext = YES;
        UIViewController *registerScene = [self.storyboard instantiateViewControllerWithIdentifier:@"register"];
        [self presentViewController:registerScene animated:NO completion:nil];
    }
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
        AppDelegate *del;
        del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (!([del.trails lastObject] == nil)){
            NSLog(@"delTrails: %@", del.trails);
            //[self.mapView addOverlay:[del.trails lastObject]];
            //need to empty resources
            //del.trails = nil;
        }
    }
    if ([viewController isKindOfClass:[viewController class]]){
        //[(ViewController *)viewController hide
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[Path class]]) {
        Path *polyLine = [Path initWithPolyline:overlay];
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)polyLine];
        aRenderer.strokeColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

# pragma mark - detect touches on MKOverlay
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(Path *)poly
{
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.polyline.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.polyline.points[n];
        MKMapPoint ptB = poly.polyline.points[n + 1];
        
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
        Path *nearestPoly = nil;
        
        // for every trail ...
        for (Path *p in self.mapView.overlays) {
            // ... get the distance ...
            float distance = [self distanceOfPoint:MKMapPointForCoordinate(coord) toPoly:p];
            
            // ... and find the nearest one
            if (distance < nearestDistance) {
                nearestDistance = distance;
                nearestPoly = p;
            }
        }
        
        if (nearestDistance <= maxMeters) {
            NSLog(@"Touched poly: %@ distance: %f", nearestPoly.categories, nearestDistance);
            //NSLog(@"touched: %@", nearestPoly.categories);
        }
    }
}

#pragma mark - Model
- (void)modelUpdated
{
    NSLog(@"Updating Model...");
    //[self.mapView addAnnotations:self.annotationArray];
    //for (id anno in self.annotationArray){
    //[self.locations addLocation:anno];
    //}
    [self refreshAnnotations];
}
- (Paths*) paths
{
    //NSLog(@"Paths Method: %@", [self paths].delegate);
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return del.paths;
}
- (void) refreshAnnotations
{
    NSLog(@"refreshing annotations");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Removing polylines");
        for (id<MKOverlay> overlay in self.mapView.overlays){
            [self.mapView removeOverlay:overlay];
        }
        
        for (id<MKOverlay> a in self.paths.filteredLocations) {
            
            [self.mapView addOverlay:a];
        }
    });
}


@end
