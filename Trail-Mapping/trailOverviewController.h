//
//  trailOverviewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/30/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface trailOverviewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *submitForm;
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
