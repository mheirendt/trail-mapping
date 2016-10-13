//
//  VertexView.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/16/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol CalloutAnnotationViewDelegate;
@interface VertexView : MKAnnotationView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *scrollingText;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, assign) id<CalloutAnnotationViewDelegate> delegate;
@end

@protocol CalloutAnnotationViewDelegate
@required
- (void)calloutButtonClicked:(NSString *)title;
@end
