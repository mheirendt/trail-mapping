//
//  ViewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//
@import MapKit;
#import <UIKit/UIKit.h>
#import "Path.h"
#import "Vertex.h"
#import "VertexView.h"
#import "CategoryView.h"

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, CalloutAnnotationViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *traceButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *completeSketch;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomToButton;
@property (strong, nonatomic) UIView *submissionView;
@property (strong, nonatomic) UIView *categoriesSelector;
@property (strong, nonatomic) UIView *backgroundView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *allLocations;
@property  Path *result;
@property (nonatomic, strong) NSTimer *timer;
@property int seconds;
@property float distance;
@property float elevation;
@property (retain, nonatomic) MKPolylineRenderer *lineView;
@property BOOL tracing;
@property BOOL submitFlag;
@property int following;
@property (strong, nonatomic) NSMutableArray *vertices;
@property (strong, nonatomic) NSMutableArray *movedCoordinates;
@property (strong, nonatomic) UIImageView *runImage;
@property (strong, nonatomic) UIImageView *bikeImage;
@property (strong, nonatomic) UIImageView *skateImage;
@property (strong, nonatomic) UIImageView *handicapImage;
@property (strong, nonatomic) NSMutableArray *categories;


#pragma mark - Hide and show the tab bar
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion;
- (BOOL)tabBarIsVisible;
@end

