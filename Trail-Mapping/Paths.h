//
//  Paths.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/4/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@class Path;

@protocol polylineModelDelegate <NSObject>
-(void)modelUpdated;
@end


@interface Paths : NSObject

@property (nonatomic, weak) id<polylineModelDelegate> delegate;
@property (nonatomic, strong) NSMutableArray* objects;

- (NSArray*) filteredLocations;
- (void) addPath:(Path*)path;

- (void) import;
- (void) persist:(Path*)path;

- (void) runQuery:(NSString*)queryString;
- (void) queryRegion:(MKCoordinateRegion)region;

@end
