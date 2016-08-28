//
//  Annotation.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(Annotation *)initWithCoordinate:(CLLocationCoordinate2D)coordinate identifier: (NSString *)name{
    Annotation *anno = [[Annotation alloc] init];
    anno.coordinate = coordinate;
    anno.name = name;
    return anno;
}

-(NSString *)title{
    return self.name;
}
@end
