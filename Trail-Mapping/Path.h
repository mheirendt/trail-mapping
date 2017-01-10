//
//  Path.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/4/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "User.h"

@interface Path : NSObject <MKOverlay>

@property (nonatomic, strong) NSString* _id;
@property (nonatomic, strong) NSDictionary *submittedUser;
@property (nonatomic, strong) NSDictionary* reference;
@property (nonatomic, strong) NSMutableArray* categories;
@property (nonatomic, strong) NSMutableArray* tags;
@property (nonatomic, strong) NSMutableArray* geometry;
@property (nonatomic, strong) NSDate* created;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) id location;
@property CLLocationCoordinate2D Coordinate;

/** This property starts out YES until modified manually or loaded from the network. This way dragging the pin will update the coordinates and geocoded info */
@property (nonatomic) BOOL configuredBySystem;


#pragma mark - JSON-ification

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (instancetype) initWithDictionary:(NSDictionary*)dictionary Polyline:(MKPolyline *)poly;
- (NSDictionary*) toDictionary;


#pragma mark - Location
- (User *) submittedUser;
- (NSMutableArray *) categories;
- (NSMutableArray *) tags;
//- (NSMutableArray *) coordinates;
- (void) setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (void) setGeoJSON:(id)geoPoint;
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;
+ (Path *) initWithPolyline: (MKPolyline *) line;

#pragma mark - MKOverlay
- (CLLocationCoordinate2D) coordinate;
- (MKMapRect) boundingMapRect;
- (BOOL)intersectsMapRect:(MKMapRect)mapRect;
- (MKMapPoint *) points;
- (NSUInteger) pointCount;
- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range;


@end


