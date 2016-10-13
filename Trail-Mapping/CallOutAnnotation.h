//
//  CallOutAnnotation.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/18/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface CallOutAnnotation : UIView <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
