//
//  Annotation.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface Annotation : MKAnnotationView

@property CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *name;

+(Annotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate identifier: (NSString *)name;
-(NSString *)title;

@end
