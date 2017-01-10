//
//  FeedPostDetailViewController.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 1/4/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "FeedPostDetailViewController.h"

@interface FeedPostDetailViewController ()

@end

@implementation FeedPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.post = [[FeedPost alloc] initWithFrame:CGRectMake(self.feedView.bounds.origin.x, self.feedView.bounds.origin.y - 20, self.feedView.bounds.size.width, self.feedView.bounds.size.height - 20)];
    [self.post setDictionary:self.dict];
    [self.feedView addSubview:_post];
    [self.feedView setNeedsDisplay];
    [self.view setNeedsDisplay];
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([_mapView mapRectThatFits:_path.boundingMapRect]);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
    self.mapView.delegate = self;
    [self.mapView addOverlay:_path];
    
    self.view.userInteractionEnabled = true;
    self.feedView.userInteractionEnabled = true;
    self.post.userInteractionEnabled = true;
}

-(void) zoomToPath:(Path *)path {
    _path = path;
    [self.mapView addOverlay:path];
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([_mapView mapRectThatFits:path.boundingMapRect]);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
}

#pragma mark - MKOverlay methods
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[Path class]]) {
        Path *polyLine = overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)polyLine];
        aRenderer.strokeColor = [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

#pragma mark - MKMapView Delegate methods
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([_mapView mapRectThatFits:self.path.boundingMapRect]);
    if ((mapView.region.span.latitudeDelta > region.span.latitudeDelta ) || (mapView.region.span.longitudeDelta > region.span.longitudeDelta) ) {
        //[mapView setRegion:[mapView regionThatFits:region] animated:YES];
        [mapView setVisibleMapRect:[mapView mapRectThatFits:_path.boundingMapRect] edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
    }
    if (fabs(fabs(mapView.region.center.latitude) - region.center.latitude) > (region.center.latitude / 2) ) {
        [mapView setVisibleMapRect:[mapView mapRectThatFits:_path.boundingMapRect] edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
        
    }
    if (fabs(fabs(mapView.region.center.longitude) - region.center.longitude) > (region.center.longitude / 2) ) {
        [mapView setVisibleMapRect:[mapView mapRectThatFits:_path.boundingMapRect] edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:YES];
    }
}

@end
