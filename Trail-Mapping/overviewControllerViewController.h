//
//  overviewControllerViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/29/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface overviewControllerViewController : UIViewController <MKMapViewDelegate>

@property (retain, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
