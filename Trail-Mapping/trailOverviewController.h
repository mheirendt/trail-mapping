//
//  trailOverviewController.h
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/30/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Path.h"
#import "ZFTokenField.h"
#import "Paths.h"

@import MapKit;

@interface trailOverviewController : UIViewController <UITextFieldDelegate, ZFTokenFieldDelegate, ZFTokenFieldDataSource>
@property (weak, nonatomic) IBOutlet UIButton *submitForm;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet ZFTokenField *tokenField;
@property (weak, nonatomic) IBOutlet UILabel *warningMessage;
@property int submitFlag;
@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) Path *path;

@end
