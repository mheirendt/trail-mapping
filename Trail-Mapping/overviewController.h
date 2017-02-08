//
//  overviewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/29/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paths.h"
#import "Path.h"
#import "FeedPostDetail.h"
#import "ErrorView.h"

@import MapKit;

@interface overviewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate, polylineModelDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) MKPolylineRenderer *lineView;


- (Paths*) paths;

-(void)startLocationManager;

- (void)modelUpdated;
@end
