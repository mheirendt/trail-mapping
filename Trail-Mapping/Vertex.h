//
//  Vertex.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/14/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@interface Vertex : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocationCoordinate2D coords;

+ (Vertex *)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end
