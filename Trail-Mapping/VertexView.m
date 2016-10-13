//
//  VertexView.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/16/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "VertexView.h"
#import "Vertex.h"

@implementation VertexView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        //initialize the frame
        self.frame = CGRectMake(0,0,141,108);
        [self setUserInteractionEnabled:YES];
        //Title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 30.0f)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:self.titleLabel];
        CGRect titleBounds = self.titleLabel.superview.bounds;
        self.titleLabel.center = CGPointMake(CGRectGetMidX(titleBounds), CGRectGetMidY(titleBounds) - 40);
        //self scolling text
        self.scrollingText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 80)];
        self.scrollingText.text = @"Press, hold, and drag this vertex to change it's location.";
        self.scrollingText.textAlignment = NSTextAlignmentCenter;
        self.scrollingText.font = [UIFont systemFontOfSize:10.f];
        self.scrollingText.lineBreakMode = NSLineBreakByWordWrapping;
        self.scrollingText.numberOfLines = 3;
        [self addSubview:self.scrollingText];
        CGRect scrollBounds = self.scrollingText.superview.bounds;
        self.scrollingText.center = CGPointMake(CGRectGetMidX(scrollBounds), CGRectGetMidY(scrollBounds) - 10);
        //Delete Button
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setFrame:CGRectMake(0, 0, 50, 50)];
        [self.button addTarget:self action:@selector(calloutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.button setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
        [self addSubview:self.button];
        CGRect bounds = self.button.superview.bounds;
        self.button.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) + 30);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    /* We can only draw inside our view, so we need to inset the actual 'rounded content' */
    CGRect contentRect = CGRectInset(rect, 0.5f, 0.5f);
    
    /* Create the rounded path and fill it */
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:contentRect cornerRadius:15.f];
    CGContextSetFillColorWithColor(ref, [UIColor whiteColor].CGColor);
    CGContextSetShadowWithColor(ref, CGSizeMake(0.0, 0.0), 15.f, [UIColor colorWithRed:.067f green:.384 blue:.384 alpha:1.f].CGColor);
    [roundedPath fill];
    
    /* Draw a subtle white line at the top of the view */
    [roundedPath addClip];
    CGContextSetStrokeColorWithColor(ref, [UIColor whiteColor].CGColor);
    CGContextSetBlendMode(ref, kCGBlendModeOverlay);
    
    CGContextMoveToPoint(ref, CGRectGetMinX(contentRect), CGRectGetMinY(contentRect)+0.5);
    CGContextAddLineToPoint(ref, CGRectGetMaxX(contentRect), CGRectGetMinY(contentRect)+0.5);
    CGContextStrokePath(ref);
}

#pragma mark - Button clicked
- (void)calloutButtonClicked
{
    Vertex *annotation = self.annotation;
    [self.delegate calloutButtonClicked:(NSString *)annotation.title];
}


@end
