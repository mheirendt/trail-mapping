//
//  Vertex.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/14/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "Vertex.h"

@implementation Vertex

-(id)init {
    if ( self = [super init] ) {
    }
    return self;
}

+ (Vertex *)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    Vertex *vertex = [[Vertex alloc] init];
    vertex.coords = coordinate;
    return vertex;
}
- (NSString *)title {
    return self.name;
}

- (CLLocationCoordinate2D)coordinate {
    return self.coords;
}


-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    self.coords = newCoordinate;
}
/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CLLocationCoordinate2D location = [_mapView convertPoint:self.center toCoordinateFromView:self.superview];
}
*/
/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event mapView:(MKMapView *)mapView sender:(UIView *)sender{
    CLLocationCoordinate2D locaion = [mapView convertPoint:CGPointMake(2, 2) toCoordinateFromView:sender.superview];
}
 */
@end
