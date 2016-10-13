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
@synthesize runImage;
@synthesize bikeImage;
@synthesize skateImage;
@synthesize handicapImage;
MKAnnotationView *mainAnnoView;
Vertex *currentVertex;
Vertex *deletedVertex;

#pragma mark - Initialize the view
- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLocationManager];
    self.mapView.delegate = self;
    self.locationManager.delegate = self;
    self.allLocations = [[NSMutableArray alloc] init];
    self.vertices = [[NSMutableArray alloc] init];
    self.movedCoordinates = [[NSMutableArray alloc] init];
    _categories = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCategoryView) name:@"categoriesDismissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categorySelected) name:@"Selection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryDeselected) name:@"Deselection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subviewDisplayed) name:@"ViewDisplayed" object:nil];
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
    } else {
        [self setTabBarVisible:![self tabBarIsVisible] animated:YES completion:nil];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        self.completeSketch.enabled = NO;
        self.completeSketch.hidden = YES;
        self.traceButton.hidden = NO;
        self.submitButton.hidden = YES;
        self.editButton.hidden = YES;
        self.saveButton.hidden = YES;
        self.zoomToButton.hidden = NO;
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
- (void)startLocationManager{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 2;
    self.locationManager.activityType = CLActivityTypeFitness;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if (_following == 2){
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (_tracing){
        for (CLLocation *newLocation in locations) {
            NSDate *eventDate = newLocation.timestamp;
            NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
            if (howRecent < 1.0/* && newLocation.speed > 1 */) {
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
                AppDelegate *del;
                del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    [UIButton beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:1];
    self.completeSketch.transform = CGAffineTransformMakeScale(1,1);
    self.completeSketch.alpha = 1.0f;
    [UIView commitAnimations];
}
- (IBAction)stopTracing:(id)sender {
    _tracing = NO;
    _following = 2;
    [self zoomToLocation:self];
    self.zoomToButton.hidden = YES;
    [self.locationManager stopUpdatingLocation];
    AppDelegate *delegate;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coordinates[delegate.trails.count];
    for (NSInteger index = 0; index < delegate.trails.count; index++){
        CLLocation *location = [delegate.trails objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
    }
    self.result = nil;
    //MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:delegate.trails.count];
    //self.result = [Path initWithPolyline:poly];
    @try{
        for (id<MKOverlay> overlay in self.mapView.overlays){
            [self.mapView removeOverlay:overlay];
        }
    }
    @catch (NSException *exception){
        NSLog(@"Eception: %@, /n Reason: %@", exception.name, exception.reason);
    }
    @try{
        MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:delegate.trails.count];
        self.result = [Path initWithPolyline:poly];
        [self.mapView addOverlay:self.result];
    }
    @catch (NSException *exception){
        NSLog(@"Eception: %@, /n Reason: %@", exception.name, exception.reason);
    }
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(self.result.boundingMapRect);
    [self.mapView setRegion:region animated:YES];
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
    [UIImageView beginAnimations:nil context:nil];
    [UIImageView setAnimationDuration:.4f];
    imageView.transform = CGAffineTransformMakeScale(3.f, 3.f);
    imageView.alpha = 0;
    [UIImageView commitAnimations];
    [self performSelector:@selector(removeImage) withObject:nil afterDelay:.4f];
    if ([self.vertices count] == 2){
        ((VertexView*)mainAnnoView).button.enabled = NO;
    } else{
        ((VertexView*)mainAnnoView).button.enabled = YES;
    }
}
- (IBAction)cancelTracing:(id)sender {
    _tracing = NO;
    _following = 2;
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    del.trails = nil;
    self.allLocations = nil;
    self.vertices = nil;
    self.movedCoordinates = nil;
    [self zoomToLocation:self];
    [self.locationManager stopUpdatingLocation];
    for (id<MKOverlay> overlay in self.mapView.overlays){
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
    self.zoomToButton.hidden = NO;
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
    mainAnnoView = (VertexView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:@"Vertex"];
    NSString *identifier;
    if (annotation == mapView.userLocation){
        identifier = @"location";
        return nil;
    } else if ([annotation isKindOfClass:[CallOutAnnotation class]]) {
        identifier = @"Callout";
        mainAnnoView = (VertexView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (mainAnnoView == nil) {
            mainAnnoView = [[VertexView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        CallOutAnnotation *calloutAnnotation = (CallOutAnnotation *)annotation;
        int intVal = [calloutAnnotation.title intValue];
        ((VertexView*)mainAnnoView).titleLabel.text = [NSString stringWithFormat:@"Vertex %d", intVal + 1];
        ((VertexView *)mainAnnoView).delegate = self;
        [mainAnnoView setCenterOffset:CGPointMake(0, -70)];
        [mainAnnoView setNeedsDisplay];
    } else {
        identifier = @"Vertex";
            if (mainAnnoView == nil) {
                mainAnnoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Vertex"];
                mainAnnoView.enabled = YES;
                mainAnnoView.draggable = YES;
                mainAnnoView.canShowCallout = NO;
                mainAnnoView.image = [UIImage imageNamed:@"Vertex.png"];
            }
    }
    mainAnnoView.annotation = annotation;
    return mainAnnoView;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    CGPoint position = mainAnnoView.center;
    CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:position toCoordinateFromView:self.view];
    Vertex *vertex = [Vertex initWithCoordinate:newCoordinate];
    [vertex setCoordinate:newCoordinate];
    [currentVertex setCoordinate:newCoordinate];
    int intVal = [currentVertex.title intValue];
    [currentVertex setName:[NSString stringWithFormat:@"%d", intVal]];
    [vertex setName:[NSString stringWithFormat:@"%d", intVal]];
    [self.vertices replaceObjectAtIndex:intVal withObject:vertex];
    [self polylineMoved];
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[Vertex class]]) {
        CallOutAnnotation *calloutAnnotation = [[CallOutAnnotation alloc] init];
        Vertex *pinAnnotation = ((Vertex *)view.annotation);
        calloutAnnotation.title = pinAnnotation.title;
        calloutAnnotation.coordinate = pinAnnotation.coordinate;
        pinAnnotation.calloutAnnotation = calloutAnnotation;
        [self.mapView addAnnotation:calloutAnnotation];
        deletedVertex = pinAnnotation;
        currentVertex = pinAnnotation;
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[Vertex class]]) {
        Vertex *pinAnnotation = ((Vertex *)view.annotation);
        [self.mapView removeAnnotation:pinAnnotation.calloutAnnotation];
        pinAnnotation.calloutAnnotation = nil;
        deletedVertex = nil;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    NSString *path = @"center";
    currentVertex = [Vertex initWithCoordinate:annotationView.annotation.coordinate];
    int intVal = [annotationView.annotation.title intValue];
    [currentVertex setName:[NSString stringWithFormat:@"%d", intVal]];
    mainAnnoView = annotationView;
    [self.vertices replaceObjectAtIndex:intVal withObject:currentVertex];
    [self polylineMoved];
    if (newState == MKAnnotationViewDragStateStarting){
        [annotationView addObserver:self forKeyPath:path options:NSKeyValueObservingOptionNew context:nil];
        [annotationView setImage:[UIImage imageNamed:@"Vertex Selected"]];
        annotationView.dragState = MKAnnotationViewDragStateDragging;
        [annotationView.annotation setCoordinate:annotationView.annotation.coordinate];
    }else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling){
        [annotationView setImage:[UIImage imageNamed:@"Vertex"]];
        annotationView.dragState = MKAnnotationViewDragStateNone;
        @try{
            [annotationView removeObserver:self forKeyPath:path];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
            NSLog(@"Something went wrong");
        }
    }
    if (newState == MKAnnotationViewDragStateEnding){
        [self polylineMoved];
    }
}

-(void)polylineMoved{
    for (id<MKOverlay> overlay in self.mapView.overlays){
        [self.mapView removeOverlay:overlay];
    }
    AppDelegate *delegate;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
- (void)calloutButtonClicked:(NSString *)title {
    int intVal = [deletedVertex.title intValue];
    for (id <MKAnnotation>  anno in [self.mapView annotations]){
        if (anno.title == deletedVertex.title){
            [self.mapView removeAnnotation:anno];
        }
    }
    for (id<MKOverlay> overlay in self.mapView.overlays){
        [self.mapView removeOverlay:overlay];
    }
    //Remove the object from the verictes array
    [self.vertices removeObjectAtIndex:intVal];
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del.trails removeAllObjects];
    CLLocationCoordinate2D coordinates[self.vertices.count];
    for (NSInteger index = 0; index < self.vertices.count; index++){
        Vertex *vertex = [self.vertices objectAtIndex:index];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:vertex.coordinate.latitude longitude:vertex.coordinate.longitude];
        CLLocationCoordinate2D coord = location.coordinate;
        coordinates[index] = coord;
        [del.trails addObject:location];
    }
    [self.vertices removeAllObjects];
    for (id <MKAnnotation>  anno in [self.mapView annotations]){
        [self.mapView removeAnnotation:anno];
    }
    CLLocationCoordinate2D coords[del.trails.count];
    for (NSInteger index = 0; index < del.trails.count; index++) {
        CLLocation *location = [del.trails objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coords[index] = coordinate;
        Vertex *annotation = [Vertex initWithCoordinate:coordinate];
        [annotation setName:[NSString stringWithFormat:@"%ld", (long)index]];
        [self.vertices addObject: annotation];
        [self.mapView addAnnotation:(id)annotation];
    }
    self.result = nil;
    MKPolyline *poly = [MKPolyline polylineWithCoordinates:coordinates count:del.trails.count];
    self.result = [Path initWithPolyline:poly];
    Path *p = [Path initWithPolyline:poly];
    [self.mapView addOverlay:p];
    if ([self.vertices count] == 2){
        ((VertexView*)mainAnnoView).button.enabled = NO;
    } else{
        ((VertexView*)mainAnnoView).button.enabled = YES;
    }
}

#pragma mark - Edit Cancel Save polyline methods
- (IBAction)editPolyline:(id)sender {
    self.submitButton.enabled = NO;
    self.saveButton.hidden = NO;
    self.completeSketch.enabled = NO;
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.movedCoordinates = nil;
    self.movedCoordinates = del.trails;
    [self.editButton removeTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton addTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [self scaleImage:_editButton.imageView Duration:.5f ScaleX:.5f ScaleY:.5f];
    for (id<MKOverlay> overlay in self.mapView.overlays){
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
    [self.mapView addOverlay:p];
}
- (IBAction)saveEdits:(id)sender {
    self.saveButton.hidden = YES;
    self.completeSketch.enabled = NO;
    [self scaleImage:self.editButton.imageView Duration:.5f ScaleX:1.f ScaleY:1.f];
    [self.editButton removeTarget:self action:@selector(cancelEdits) forControlEvents:UIControlEventTouchUpInside];
    [self.editButton setImage:[UIImage imageNamed:@"Edit Trace"] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editPolyline:) forControlEvents:UIControlEventTouchUpInside];
    for (id <MKAnnotation> annotation in self.mapView.annotations){
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            [self.mapView removeAnnotation:annotation];
        }
    }
    for (id<MKOverlay> overlay in self.mapView.overlays){
        [self.mapView removeOverlay:overlay];
    }
    self.submitButton.enabled = YES;
    AppDelegate *delegate;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    [self.vertices removeAllObjects];
    [self.mapView addOverlay:self.result];
}
-(void)cancelEdits{
    [self.vertices removeAllObjects];
    AppDelegate *delegate;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.trails = nil;
    delegate.trails = self.movedCoordinates;
    self.saveButton.hidden = YES;
    self.submitButton.enabled = YES;
    self.completeSketch.enabled = NO;
    [self scaleImage:self.editButton.imageView Duration:.5f ScaleX:1.f ScaleY:1.f];
    for (id <MKAnnotation> annotation in self.mapView.annotations){
        if (![annotation isKindOfClass:[MKUserLocation class]]){
            [self.mapView removeAnnotation:annotation];
        }
    }
    for (id<MKOverlay> overlay in self.mapView.overlays){
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
-(void)showOverviewController {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"trailOverview"] animated:YES completion:^{
        MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
        ulv.hidden = NO;
        self.mapView.userInteractionEnabled = YES;
        self.submitButton.hidden = YES;
        self.traceButton.hidden = NO;
        self.completeSketch.hidden = YES;
        self.cancelButton.hidden = YES;
        self.editButton.hidden = YES;
        self.submitFlag = YES;
        AppDelegate *del;
        del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        del.submittedPath = self.result;
        NSLog(@"pre del: %@", self.vertices);
        del.submittedPath.vertices = del.trails;
        NSLog(@"Before trans: %@", del.submittedPath.vertices);
        for (id<MKOverlay> overlay in self.mapView.overlays){
            [self.mapView removeOverlay:overlay];
        }
        self.submissionView.frame = CGRectNull;
        self.submissionView = nil;
    }];
}
#pragma mark - build and show the submission view to select category
-(IBAction)showSubmissionView:(id)sender{
    if (!_submissionView){
       // _submissionView = [[UIView alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height-110, self.view.bounds.size.width-15, self.view.bounds.size.height/2)];
        _submissionView = [[UIView alloc] initWithFrame:CGRectZero];
        _submissionView.backgroundColor = [UIColor whiteColor];
        _submissionView.layer.borderWidth = 3.f;
        _submissionView.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
        _submissionView.layer.cornerRadius = 30.f;
        
        self.submissionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_submissionView];
        
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_submissionView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:.5f
                                                               constant:250]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_submissionView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:.95f
                                                               constant:10.f]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_submissionView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:25.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_submissionView
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:.95f
                                                               constant:10.f]];
        

        
    }
    self.mapView.userInteractionEnabled = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_submissionView.bounds];
    _submissionView.layer.shadowPath = path.CGPath;
    CGRect frame = CGRectMake(10, (self.view.bounds.size.height/2) + 30, self.view.bounds.size.width-15, (self.view.bounds.size.height/2));
    [UIView animateWithDuration:0.5f animations:^{
        _submissionView.frame = frame;
    } completion:^(BOOL finished) {
        if(finished){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDisplayed" object:self];
        }
    }];
}
-(void)subviewDisplayed{
    //Title label
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(0, 0, 180.f, 35.f);
    [titleButton addTarget:self action:@selector(showCategorySelector) forControlEvents:UIControlEventTouchUpInside];
    titleButton.backgroundColor = [UIColor whiteColor];
    titleButton.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    titleButton.layer.borderWidth = 2.f;
    titleButton.layer.cornerRadius = 15.f;
    [_submissionView addSubview:titleButton];
    CGRect titleBounds = titleButton.superview.bounds;
    titleButton.center = CGPointMake(CGRectGetMidX(titleBounds), CGRectGetMidY(titleBounds) - 100);
    UILabel *lab = [[UILabel alloc] initWithFrame:titleButton.frame];
    lab.center = titleButton.center;
    lab.textAlignment = NSTextAlignmentCenter;
    [lab setFont:[UIFont systemFontOfSize:22]];
    [lab setText:@"Choose Activity"];
    [_submissionView addSubview:lab];
    
    //Categories Images
    //1
    CGRect frame = CGRectMake(0, 0, 65, 65);
    runImage = [[UIImageView alloc] initWithFrame:frame];
    [runImage setImage:[UIImage imageNamed:@"Run"]];
    runImage.hidden = YES;
    [_submissionView addSubview:runImage];
    CGRect bounds = runImage.superview.bounds;
    runImage.center = CGPointMake(CGRectGetMidX(bounds) - 105, CGRectGetMidY(bounds) - 20);
    //2
    bikeImage = [[UIImageView alloc] initWithFrame:frame];
    [bikeImage setImage:[UIImage imageNamed:@"Bike"]];
    bikeImage.hidden = YES;
    [_submissionView addSubview:bikeImage];
    bikeImage.center = CGPointMake(CGRectGetMidX(bounds) - 35, CGRectGetMidY(bounds) - 20);
    //3
    skateImage = [[UIImageView alloc] initWithFrame:frame];
    [skateImage setImage:[UIImage imageNamed:@"Skate"]];
    skateImage.hidden = YES;
    [_submissionView addSubview:skateImage];
    skateImage.center = CGPointMake(CGRectGetMidX(bounds) + 35, CGRectGetMidY(bounds) - 20);
    //4
    handicapImage = [[UIImageView alloc] initWithFrame:frame];
    [handicapImage setImage:[UIImage imageNamed:@"Handicap"]];
    handicapImage.hidden = YES;
    [_submissionView addSubview:handicapImage];
    handicapImage.center = CGPointMake(CGRectGetMidX(bounds) + 105, CGRectGetMidY(bounds) - 20);
    
    //Upload Button
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setFrame:CGRectMake(0, 0, 50, 50)];
    [nextButton addTarget:self action:@selector(showOverviewController) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setImage:[UIImage imageNamed:@"Upload"] forState:UIControlStateNormal];
    [_submissionView addSubview:nextButton];
    nextButton.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + 60);
    
}
-(void)showCategorySelector{
    _backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = .5f;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCategoryView)];
    [_backgroundView addGestureRecognizer:recognizer];
    [self.view addSubview:_backgroundView];
    if (!_categoriesSelector){
        _categoriesSelector = [[categoryView alloc] initWithFrame:CGRectMake(0, 0, 250, 375)];
        _categoriesSelector.backgroundColor = [UIColor whiteColor];
        CGRect viewBounds = self.view.bounds;
        _categoriesSelector.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds) - 70);
        _categoriesSelector.layer.borderWidth = 1.5f;
        _categoriesSelector.layer.borderColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor;
    }
    [self.view addSubview:_categoriesSelector];
}
-(void)categorySelected{
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSString *string in del.categories) {
        if ([string isEqualToString:@"Run"])
            runImage.hidden = NO;
        if ([string isEqualToString:@"Bike"])
            bikeImage.hidden = NO;
        if ([string isEqualToString:@"Skate"])
            skateImage.hidden = NO;
        if ([string isEqualToString:@"Handicap"])
            handicapImage.hidden = NO;
        
    }
}
-(void)categoryDeselected{
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *string = del.deselection;
    if ([string isEqualToString:@"Run"])
        runImage.hidden = YES;
    if ([string isEqualToString:@"Bike"])
        bikeImage.hidden = YES;
    if ([string isEqualToString:@"Skate"])
        skateImage.hidden = YES;
    if ([string isEqualToString:@"Handicap"])
        handicapImage.hidden = YES;
}
-(void)dismissCategoryView{
    [self.categoriesSelector removeFromSuperview];
    [UIView animateWithDuration:0.5 delay:0.f options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.backgroundView.alpha = 0;
    }
completion:^(BOOL finished){
    [self.backgroundView removeFromSuperview];
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
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del.trails removeAllObjects];
    [self.vertices removeAllObjects];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.mapView.userInteractionEnabled = YES;
    if (_submissionView){
        [_submissionView removeFromSuperview];
    }
    
    self.completeSketch.enabled = NO;
    self.completeSketch.hidden = YES;
    self.traceButton.hidden = NO;
    self.submitButton.hidden = YES;
    self.editButton.hidden = YES;
    self.saveButton.hidden = YES;
     [self scaleImage:self.editButton.imageView Duration:.5f ScaleX:1.f ScaleY:1.f];
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
    self.submissionView.frame = CGRectNull;
    self.submissionView = nil;
}

@end
