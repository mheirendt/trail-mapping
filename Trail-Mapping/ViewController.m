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

#pragma mark - Initialize the view

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocationManager];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.allLocations = [[NSMutableArray alloc] init];
    self.vertices = [[NSMutableArray alloc] init];
    self.movedCoordinates = [[NSMutableArray alloc] init];
    
}
-(void)viewDidAppear:(BOOL)animated{
    UILabel *attributionLabel = [self.mapView.subviews objectAtIndex:1];
    attributionLabel.center = CGPointMake(345, 60);
    _following = 1;
    if (self.submitFlag){
        [self.tabBarController setSelectedIndex:0];
        [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
        }];
        self.submitFlag = NO;
    } else{
        [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:nil];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        self.completeSketch.enabled = NO;
        self.completeSketch.hidden = YES;
        self.traceButton.hidden = NO;
        self.submitButton.hidden = YES;
        self.editButton.hidden = YES;
        self.saveButton.hidden = YES;
        for (id <MKAnnotation> annotation in self.mapView.annotations)
        {
            if (![annotation isKindOfClass:[MKUserLocation class]])
            {
                [self.mapView removeAnnotation:annotation];
            }
        }
        [self.editButton removeTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
        [self.editButton setImage:[UIImage imageNamed:@"Edit Trace"] forState:UIControlStateNormal];
        [self.editButton addTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Location services
- (void)startLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 2;
    self.locationManager.activityType = CLActivityTypeFitness;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_following == 2){
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (_tracing){
        for (CLLocation *newLocation in locations) {
            NSDate *eventDate = newLocation.timestamp;
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
            NSLog(@"speed: %f", newLocation.speed);
            if (howRecent < 1.0/* && newLocation.speed > 1 */) {
                NSLog(@"distance: %f", self.distance);
                if (self.allLocations.count > 0) {
                    self.distance += [newLocation distanceFromLocation:self.allLocations.lastObject];
                    CLLocationCoordinate2D coords[2];
                    coords[0] = ((CLLocation *)self.allLocations.lastObject).coordinate;
                    coords[1] = newLocation.coordinate;
                    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coords count:2];
                    Path *path = [Path initWithPolyline:poly];
                    [self.mapView addOverlay:path];
                }
                [self.allLocations addObject:newLocation];
                AppDelegate *del = [[UIApplication sharedApplication] delegate];
                [del.trails addObject:[locations lastObject]];
                if (del.trails.count > 1){
                    self.completeSketch.enabled = YES;
                }
            }
        }
    }
}

- (IBAction)zoomToLocation:(id)sender {
    if (_following == 1){
        _following = 2;
        [self.zoomToButton setImage:[UIImage imageNamed:@"Zoom Invert"] forState:UIControlStateNormal];
        [self animateButton];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                      target:self selector:@selector(animateButton) userInfo:nil repeats:YES];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        [self.zoomToButton setImage:[UIImage imageNamed:@"Zoom"] forState:UIControlStateNormal];
        _following = 1;
    }
}

#pragma mark - Methods to show and hide tracing actions
- (IBAction)tracePath:(id)sender {
    _following = 1;
    _tracing = YES;
    [self zoomToLocation:self];
    self.cancelButton.hidden = NO;
    self.seconds = 0;
    self.distance = 0;
    self.allLocations = [NSMutableArray array];
    [self.locationManager startUpdatingLocation];
    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
    ulv.hidden = NO;
    self.traceButton.hidden = YES;
    self.completeSketch.hidden = NO;
    self.editButton.hidden = YES;
    self.submitButton.hidden = YES;
    self.completeSketch.transform = CGAffineTransformMakeScale(1.5,1.5);
    self.completeSketch.alpha = 0.0f;
    [UIView beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:1];
    self.completeSketch.transform = CGAffineTransformMakeScale(1,1);
    self.completeSketch.alpha = 1.0f;
    [UIView commitAnimations];
}
- (IBAction)stopTracing:(id)sender {
    _tracing = NO;
    _following = 2;
    [self zoomToLocation:self];
    [self.locationManager stopUpdatingLocation];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coordinates[delegate.trails.count];
    for (NSInteger index = 0; index < delegate.trails.count; index++)
    {
        CLLocation *location = [delegate.trails objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
    }
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:delegate.trails.count];
    self.result = [Path initWithPolyline:poly];
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(self.result.boundingMapRect);
    [self.mapView setRegion:region animated:YES];
    [self.mapView addOverlay:self.result];
    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
    ulv.hidden = YES;
    self.traceButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.submitButton.hidden = NO;
    self.editButton.hidden = NO;
    self.completeSketch.hidden = YES;
    [delegate.trails addObject:self.result];
    //Animate the ring around button
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScalableRing"] highlightedImage:nil];
    imageView.frame = self.completeSketch.frame;
    imageView.tag = 1;
    [self.view addSubview:imageView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    imageView.transform = CGAffineTransformMakeScale(3.f, 3.f);
    imageView.alpha = 0;
    [UIView commitAnimations];
    [self performSelector:@selector(removeImage) withObject:nil afterDelay:.4f];
}
- (IBAction)cancelTracing:(id)sender {
    _tracing = NO;
    _following = 2;
    AppDelegate *del = [[UIApplication sharedApplication] delegate];
    del.trails = nil;
    self.allLocations = nil;
    self.vertices = nil;
    self.movedCoordinates = nil;
    [self zoomToLocation:self];
    [self.locationManager stopUpdatingLocation];
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    [self.editButton removeTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"Edit Trace"] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    MKAnnotationView *userLocation = [self.mapView viewForAnnotation:self.mapView.userLocation];
    userLocation.hidden = NO;
    self.cancelButton.hidden = YES;
    self.traceButton.hidden = NO;
    self.submitButton.hidden = YES;
    self.completeSketch.hidden = YES;
    self.editButton.hidden = YES;
    self.saveButton.hidden = YES;
    //Animate the ring around the button to be scaled outward
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScalableCancel"] highlightedImage:nil];
    imageView.frame = self.cancelButton.frame;
    imageView.tag = 1;
    [self.view addSubview:imageView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    imageView.transform = CGAffineTransformMakeScale(3.f, 3.f);
    imageView.alpha = 0;
    [UIView commitAnimations];
    [self performSelector:@selector(removeImage) withObject:nil afterDelay:.4f];
}

#pragma mark - MKOverlay methods
/*
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    self.lineView =[[MKPolylineRenderer alloc] initWithPolyline:overlay];
    self.lineView.strokeColor = [UIColor orangeColor];
    self.lineView.lineWidth = 3.0;
    return self.lineView;
}
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[Path class]]) {
        Path *polyLine = overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)polyLine];
        aRenderer.strokeColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

#pragma mark - Methods for annotation views
- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id) annotation {
    MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"Vertex"];
    if (annotation == mapView.userLocation){
        return nil;
    } else {
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Vertex"];
                annotationView.enabled = YES;
                annotationView.draggable = YES;
                annotationView.canShowCallout = YES;
                annotationView.image = [UIImage imageNamed:@"Vertex.png"];
            }
    }
    return annotationView;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateStarting)
    {
        [annotationView setImage:[UIImage imageNamed:@"Vertex Selected"]];
        annotationView.dragState = MKAnnotationViewDragStateDragging;
    }     else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling)
    {
        [annotationView setImage:[UIImage imageNamed:@"Vertex"]];
        annotationView.dragState = MKAnnotationViewDragStateNone;
    }
    if (newState == MKAnnotationViewDragStateEnding)
    {
        [self polylineMoved];
    }
}

-(void)polylineMoved{
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.trails removeAllObjects];
    CLLocationCoordinate2D coordinates[self.vertices.count];
    for (NSInteger index = 0; index < self.vertices.count; index++) {
        Vertex *location = [self.vertices objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [delegate.trails addObject:loc];
    }
    self.result = nil;
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:self.vertices.count];
    self.result = [Path initWithPolyline:poly];
    [self.mapView addOverlay:self.result];
}

#pragma mark - Edit Cancel Save polyline methods
- (IBAction)editPolyline:(id)sender {
    self.submitButton.enabled = NO;
    self.saveButton.hidden = NO;
    self.completeSketch.enabled = NO;
    AppDelegate *del = [[UIApplication sharedApplication] delegate];
    self.movedCoordinates = nil;
    self.movedCoordinates = del.trails;
    [self.editButton removeTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton addTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [self scaleImage:_editButton.imageView Duration:.5f ScaleX:.5f ScaleY:.5f];
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    CLLocationCoordinate2D coordinates[del.trails.count];
    for (NSInteger index = 0; index < del.trails.count; index++) {
        CLLocation *location = [del.trails objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        Vertex *annotation = [Vertex initWithCoordinate:coordinate];
        [annotation setName:[NSString stringWithFormat:@"%ld", (long)index]];
        [self.vertices addObject: annotation];
        [self.mapView addAnnotation:(id)annotation];
    }
    self.result = nil;
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:del.trails.count];
    self.result = [Path initWithPolyline:poly];
    Path *p = [Path initWithPolyline:poly];
    NSLog(@"Self.result: %lu", [self.result pointCount]);
    [self.mapView addOverlay:p];
}
- (IBAction)saveEdits:(id)sender {
    //[self.vertices removeAllObjects];
    self.saveButton.hidden = YES;
    self.completeSketch.enabled = NO;
    [self scaleImage:self.editButton.imageView Duration:.5f ScaleX:1.f ScaleY:1.f];
    [self.editButton removeTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"Edit Trace"] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
        
    }
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    self.submitButton.enabled = YES;
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.trails removeAllObjects];
    CLLocationCoordinate2D coordinates[self.vertices.count];
    for (NSInteger index = 0; index < self.vertices.count; index++) {
        Vertex *location = [self.vertices objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [delegate.trails addObject:loc];
    }
    self.result = nil;
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:self.vertices.count];
    self.result = [Path initWithPolyline:poly];
    NSLog(@"Path: %@", self.result.coordinates);
    [self.mapView addOverlay:self.result];
}
-(void)cancelEdits{
    [self.vertices removeAllObjects];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.trails = nil;
    delegate.trails = self.movedCoordinates;
    NSLog(@"deltrails: %@", delegate.trails);
    self.saveButton.hidden = YES;
    self.submitButton.enabled = YES;
    self.completeSketch.enabled = NO;
    [self scaleImage:self.editButton.imageView Duration:.5f ScaleX:1.f ScaleY:1.f];
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        if (![annotation isKindOfClass:[MKUserLocation class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
    }
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    [self.editButton removeTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"Edit Trace"] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    
    CLLocationCoordinate2D coordinates[self.movedCoordinates.count];
    for (NSInteger index = 0; index < self.movedCoordinates.count; index++) {
        CLLocation *location = [self.movedCoordinates objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinates[index] = coordinate;
    }
    self.result = nil;
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:self.movedCoordinates.count];
    self.result = [Path initWithPolyline:poly];
    [self.mapView addOverlay:self.result];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScalableCancel"] highlightedImage:nil];
    imageView.frame = self.editButton.frame;
    imageView.tag = 1;
    [self.view addSubview:imageView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.4f];
    imageView.transform = CGAffineTransformMakeScale(3.f, 3.f);
    imageView.alpha = 0;
    [UIView commitAnimations];
    [self performSelector:@selector(removeImage) withObject:nil afterDelay:.4f];
}

#pragma mark - Animation methods
-(void)removeImage{
    NSArray *viewsToRemove = [self.view subviews];
    for (UIView *v in viewsToRemove) {
        if (v.tag == 1){
            [v removeFromSuperview];
        }
    }
}
-(void)animateButton{
    [UIView beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:2];
    self.zoomToButton.transform = CGAffineTransformMakeScale(2,2);
    self.zoomToButton.transform = CGAffineTransformMakeScale(1,1);
    self.zoomToButton.transform = CGAffineTransformMakeScale(2,2);
    self.zoomToButton.transform = CGAffineTransformMakeScale(1,1);
    [UIView commitAnimations];
}

-(void)rotateImage:(UIImageView *)view Duration:(float)duration Angle:(float)angle{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    view.transform = CGAffineTransformMakeRotation(angle); // if angle is in radians
    [UIView commitAnimations];
}
-(void)scaleImage:(UIImageView *)view Duration:(float)duration ScaleX:(float)scaleX ScaleY:(float)scaleY{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    view.transform = CGAffineTransformMakeScale(scaleX,scaleY);
    [UIView commitAnimations];
}

#pragma mark - Hide and show the tab bar

// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

#pragma mark - Methods for navigation to and from view controller
-(IBAction)showOverviewController:(id)sender{
    [self.tabBarController showViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"trailOverview"]sender:self];
    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
    ulv.hidden = NO;
    self.submitButton.hidden = YES;
    self.traceButton.hidden = NO;
    self.completeSketch.hidden = YES;
    self.cancelButton.hidden = YES;
    self.editButton.hidden = YES;
    self.submitFlag = YES;
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    
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


-(IBAction)closeWindow:(id)sender{
    _tracing = NO;
    [self.locationManager stopUpdatingLocation];
    for (id<MKOverlay> overlay in self.mapView.overlays)
    {
        [self.mapView removeOverlay:overlay];
    }
    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
    ulv.hidden = NO;
    self.cancelButton.hidden = YES;
    self.traceButton.hidden = NO;
    self.submitButton.hidden = YES;
    self.completeSketch.hidden = YES;
    [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:nil];
    [self.tabBarController setSelectedIndex:0];
}



@end
