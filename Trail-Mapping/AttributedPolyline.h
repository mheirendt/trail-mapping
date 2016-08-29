//
//  AttributedPolyline.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AttributedPolyline : MKPolyline
@property (retain, nonatomic) NSString *Name;
@property (retain, nonatomic) NSString *Category;
@property (retain, nonatomic) NSString *SubmittedUser;

-(NSString *)Name;
-(void)setName:(NSString *)Name;
-(NSString *)Category;
-(NSString *)SubmittedUser;

@end
