//
//  Path.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/4/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "Path.h"

#define safeSet(d,k,v) if (v) d[k] = v;


@implementation Path
@synthesize boundingMapRect;
@synthesize coordinate;
@synthesize polyline;

- (instancetype) init
{
    self = [super init];
    self.tags = [[NSMutableArray alloc] init];
    self.categories = [[NSMutableArray alloc] init];
    self.geometry = [[NSMutableArray alloc] init];
    self.created = [NSDate alloc];
    return self;
}

+ (Path *)initWithPolyline: (MKPolyline *) line{
    Path *path = [[Path alloc] init];
    path.polyline = line;
    return path;
}

#pragma mark - custom attributes
/*
- (NSMutableArray *)categories
{
    return self.categories;
}
- (NSMutableArray *)tags
{
    return self.tags;
}
- (NSMutableArray *)coordinates
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D coordinates[self.vertices.count];
    for (NSInteger index = 0; index < self.vertices.count; index++) {
        //CLLocation *location = [self.vertices.count objectAtIndex:index];
        //CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinates[index].latitude longitude:coordinates[index].longitude];
        [arr addObject: location];
    }
    return arr;
}
 */
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    [self setLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
}

#pragma mark - MKOverlay

- (CLLocationCoordinate2D) coordinate {
    return [polyline coordinate];
}

- (MKMapRect) boundingMapRect {
    return [polyline boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [polyline intersectsMapRect:mapRect];
}

- (MKMapPoint *) points {
    return [polyline points];
}


- (NSUInteger) pointCount {
    return [polyline pointCount];
}

- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range {
    return [polyline getCoordinates:coords range:range];
}

#pragma mark - GeoJSON

- (void) setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
{
    //make a geoJSON object e.g. { "type": "Point", "coordinates": [100.0, 0.0] }
    _location = @{@"type":@"Point", @"coordinates" : @[@(longitude), @(latitude)] };
}

- (void) setGeoJSON:(id)geoPoint
{
    _location = geoPoint;
}

#pragma mark - serialization

- (instancetype) initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        NSArray * arr = [dictionary allKeys];
        NSLog(@"dict: %@", arr);
        __id = dictionary[@"_id"];
        _submittedUser = dictionary[@"submittedUser"];
        _categories = dictionary[@"categories"];
        _tags = dictionary[@"tags"];
        _geometry = dictionary[@"geometry"];
        _created = dictionary[@"created"];
        
        CLLocationCoordinate2D coordinates[_geometry.count];
        for (NSInteger index = 0; index < _geometry.count; index++){
            //Vertex *vertex = [p.vertices objectAtIndex:index];
            //
            NSArray *arr = [_geometry objectAtIndex:index];
            NSNumber *longitude = [arr objectAtIndex:0];
            NSNumber *latitude = [arr objectAtIndex:1];
            
            //NSLog(@"arr: %@, %@", longitude, latitude);
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
            CLLocationCoordinate2D coord = location.coordinate;
            coordinates[index] = coord;
        }
        
        self.polyline = [MKPolyline polylineWithCoordinates:coordinates count:_geometry.count];
    }
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary*)dictionary Polyline:(MKPolyline *)poly
{
    self = [super init];
    if (self) {
        __id = dictionary[@"_id"];
        _submittedUser = dictionary[@"submittedUser"];
        _categories = dictionary[@"categories"];
        _tags = dictionary[@"tags"];
        _geometry = dictionary[@"geometry"];
        //_created = dictionary[@"created"];
        
        self.polyline = poly;
    }
    return self;
}


- (NSDictionary*) toDictionary
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger index = 0; index < _geometry.count; index++) {
        CLLocation *location = [_geometry objectAtIndex:index];
        CLLocationCoordinate2D theCoord = location.coordinate;
        NSArray *coords = [NSArray arrayWithObjects:[NSNumber numberWithDouble:theCoord.longitude], [NSNumber numberWithDouble:theCoord.latitude], nil];
        [array addObject:coords];
    }
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"submittedUser", self.submittedUser);
    safeSet(jsonable, @"categories", self.categories);
    safeSet(jsonable, @"tags", self.tags);
    //safeSet(jsonable, @"created", self.created);
    safeSet(jsonable, @"geometry", array);
    
    return jsonable;
}

@end
