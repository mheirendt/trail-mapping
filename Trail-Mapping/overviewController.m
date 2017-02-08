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
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:tap];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [del.paths import];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setTabBarVisible:YES animated:YES completion:nil];
    NSString *flag = [[NSUserDefaults standardUserDefaults] objectForKey:@"signin"];
    //NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if ([flag isEqualToString:@"signin"]){
        UIViewController *registerScene = [self.storyboard instantiateViewControllerWithIdentifier:@"introScene"];
        [self.navigationController pushViewController:registerScene animated:YES];//presentViewController:registerScene animated:NO completion:nil];
    }
    if ([flag isEqualToString:@"register"]){
        UIViewController *registerScene = [self.storyboard instantiateViewControllerWithIdentifier:@"introScene"];
        [self.navigationController pushViewController:registerScene animated:YES]; //presentViewController:registerScene animated:NO completion:nil];
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
        AppDelegate *del;
        del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(Path *)poly {
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
            id block = ^{
                NSURL* url = [NSURL URLWithString:[@"https://secure-garden-50529.herokuapp.com/user/search/id/" stringByAppendingString:[[nearestPoly submittedUser] valueForKey:@"_id"]]];
                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.f];
                request.HTTPMethod = @"GET";
                [request addValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
                NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error == nil) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            if ([httpResponse statusCode] == 200) {
                                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                FeedPostDetail *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FeedPostDetailViewController"];
                                //NSMutableArray *coordGeom = [[NSMutableArray alloc] init];
                                vc.dict = [[NSMutableDictionary alloc] initWithDictionary:[nearestPoly toDictionary]];
                                [vc.dict setValue:dict forKey:@"submittedUser"];
                                vc.path = nearestPoly;
                                [self.navigationController pushViewController:vc animated:YES];
                            } else {
                               [self showErrorMessage:[NSHTTPURLResponse localizedStringForStatusCode: [httpResponse statusCode]]];
                            }
                        } else {
                            [self showErrorMessage:[error localizedDescription]];
                        }
                    });
                }];
                [dataTask resume];
            };
            //Create a Grand Central Dispatch queue and run the operation async
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, block);
        }
    }
}

-(void) createAndAddAnnotationForCoordinate : (CLLocationCoordinate2D) coordinate title: (NSNumber *)title subtitle: (NSMutableArray *)subtitle{
    MKPointAnnotation* annotation= [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    NSString *newTitle = [title stringValue];
    NSString *newSub = [subtitle description];
    annotation.title = newTitle;
    annotation.subtitle = newSub;
    [_mapView addAnnotation: annotation];
}


#pragma mark - Model
- (void)modelUpdated
{
    [self refreshAnnotations];
}
- (Paths*) paths
{
    AppDelegate *del;
    del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return del.paths;
}
- (void) refreshAnnotations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *enumerate = [self.mapView.overlays copy];
        for (id<MKOverlay> overlay in enumerate){
            [self.mapView removeOverlay:overlay];
        }
        NSArray *locations = [self.paths.filteredLocations copy];
        for (id<MKOverlay> a in locations) {
            [self.mapView addOverlay:a];
        }
    });
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

-(void) showErrorMessage: (NSString *) message {
    ErrorView *errorView = [[ErrorView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    [self.view addSubview:errorView];
    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        errorView.frame  = CGRectMake(0, 0, self.view.frame.size.width, 50);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.5 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            errorView.frame  = CGRectMake(0, 0, self.view.frame.size.width, 0);
            
        } completion:^(BOOL finished) {
            [errorView removeFromSuperview];
        }];
    }];
}

@end
