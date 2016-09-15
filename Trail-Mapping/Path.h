//
//  Path.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/4/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Path : NSObject <MKOverlay>

@property (nonatomic, copy) NSString* _id;
//@property (nonatomic, copy) NSMutableArray* tags;
@property (nonatomic, copy) NSMutableArray* categories;
@property (nonatomic, retain) NSMutableArray* vertices;
@property (nonatomic, retain) MKPolyline *polyline;
@property (nonatomic, retain) id location;

/** This property starts out YES until modified manually or loaded from the network. This way dragging the pin will update the coordinates and geocoded info */
@property (nonatomic) BOOL configuredBySystem;


#pragma mark - JSON-ification

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) toDictionary;

#pragma mark - Location
- (NSMutableArray *) categories;
//- (NSMutableArray *) tags;
- (NSMutableArray *) coordinates;
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


