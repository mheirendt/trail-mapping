//
//  ErrorView.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/2/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorView : UIView

@property (strong, nonatomic) UILabel* errorLabel;

-(void) setErrorMessage: (NSString *)message;

@end
