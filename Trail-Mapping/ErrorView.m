//
//  ErrorView.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/2/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "ErrorView.h"

@implementation ErrorView


- (void)drawRect:(CGRect)rect {
    self.clipsToBounds = YES;
    [self.layer setBackgroundColor:[UIColor redColor].CGColor];
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x + 10, rect.origin.y + 10, rect.size.width - 40, rect.size.height - 40)];
    [_errorLabel setTextColor:[UIColor whiteColor]];
    
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

-(void) setErrorMessage: (NSString *)message {
    [_errorLabel setText:message];
}


@end
