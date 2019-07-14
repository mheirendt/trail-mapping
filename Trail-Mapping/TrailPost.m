//
//  TrailPost.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 2/7/17.
//  Copyright © 2017 Michael Heirendt. All rights reserved.
//

#import "TrailPost.h"

#define safeSet(d,k,v) if (v) d[k] = v;

@implementation TrailPost

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.headerView.userInteractionEnabled = YES;
        self.bodyView.userInteractionEnabled = YES;
        self.avatar.userInteractionEnabled = YES;
        [self.avatar.layer setBorderColor:[UIColor colorWithRed:.0706 green:.3137 blue:.3137 alpha:1.f].CGColor];
        
    }
    return self;
}



#pragma mark - helper methods

-(void) setDictionary:(NSDictionary *)dictionary {
    if (![self._id isEqualToString:[dictionary objectForKey:@"_id"]]) {
        self._id = dictionary[@"_id"];
    }
    if (![[self.submittedUser objectForKey:@"_id"] isEqualToString:[dictionary objectForKey:@"submittedUser"]]) {
        self.submittedUser = dictionary[@"submittedUser"];
        if ([self.submittedUser objectForKey:@"avatar" ]) {
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSString *urlStr = [@"https://secure-garden-50529.herokuapp.com/upload/" stringByAppendingString:[self.submittedUser objectForKey:@"avatar" ]];
                NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlStr]];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.avatar setImage:[UIImage imageWithData:data]];
                });
            });
        }
    }
    if (![[_reference objectForKey:@"_id" ] isEqualToString:[dictionary objectForKey:@"reference"]]) {
        _reference = dictionary[@"reference"];
    }
    if (![_body isEqualToString:[dictionary objectForKey:@"body"]]) {
        _body = dictionary[@"body"];
    }
    if (![self.likes isEqualToArray:[dictionary objectForKey:@"likes"]]) {
        self.likes = dictionary[@"likes"];
    }
    if ([self.comments isEqualToString:[dictionary objectForKey:@"comments"]]) {
        self.comments = dictionary[@"comments"];
    }
    if (![self.created isEqual:[dictionary objectForKey:@"created"]]) {
        self.created = dictionary[@"created"];
    }
    
    User *user = [[User alloc] initWithDictionary:self.submittedUser];
    Path *path = [[Path alloc] initWithDictionary:_reference];
    
    [self setupCategoryIcons:path.categories];
    
    //self.bodyText.text = self.body;
    self.username.text = user.username;
    self.likesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.likes.count];//[NSString stringWithFormat:@"%lu Likes", _likes.count];
    self.commentsLabel.text = [NSString stringWithFormat:@"%@ Comments", self.comments];
    //[self checkLikes];
}

-(void) setupCategoryIcons:(NSArray *) categories {
    for (int i = 0; i < categories.count; i++) {
        NSString *cat = categories[i];
        i == 0 ? self.imageCenter.image = [UIImage imageNamed:cat] : nil;
        i == 1 ? self.imageLeft1.image = [UIImage imageNamed:cat] : nil;
        i == 2 ?self.imageRight1.image = [UIImage imageNamed:cat] : nil;
        i == 3 ?self.imageLeft2.image = [UIImage imageNamed:cat] : nil;
        i == 4 ?self.imageRight2.image = [UIImage imageNamed:cat] : nil;
    }
}


- (NSDictionary*) toDictionary {
    
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"submittedUser", self.submittedUser);
    safeSet(jsonable, @"reference", self.reference);
    safeSet(jsonable, @"body", self.body);
    safeSet(jsonable, @"likes", self.likes);
    safeSet(jsonable, @"comments", self.comments);
    safeSet(jsonable, @"created", self.created);
    
    return jsonable;
}

- (void) persist:(TrailPost*)post
{
    NSString* posts = @"https://secure-garden-50529.herokuapp.com/posts";
    NSURL* url = [NSURL URLWithString:posts];
    NSDictionary *dictionary = [post toDictionary];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSData* data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Posted");
        } else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [dataTask resume];
}


@end

