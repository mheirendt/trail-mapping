//
//  overviewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/29/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface overviewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITabBarControllerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) MKPolylineRenderer *lineView;


-(void)startLocationManager;

@end
