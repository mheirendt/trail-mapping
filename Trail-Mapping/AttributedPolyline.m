//
//  AttributedPolyline.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 8/28/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "AttributedPolyline.h"

@implementation AttributedPolyline

-(NSString *)Name{
    return self.Name;
}
-(void)setName:(NSString *)Name{
    self.Name = Name;
}
-(NSString *)Category{
    return self.Category;
}
-(NSString *)SubmittedUser{
    return self.SubmittedUser;
}

@end
