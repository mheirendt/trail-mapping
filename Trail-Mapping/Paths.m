//
//  Paths.m
//  Trail-Mapping
//
//  Created by Michael Heirendt on 9/4/16.
//  Copyright © 2016 Michael Heirendt. All rights reserved.
//

#import "Paths.h"
#import "Path.h"
#import "overviewController.h"

static NSString* const kBaseURL = @"https://secure-garden-50529.herokuapp.com/";
static NSString* const kPaths = @"paths";


@implementation Paths

- (id)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
    }
    return self;
}

- (NSArray*) filteredLocations
{
    return [self objects];
}

- (void) addPath:(Path*)path
{
    [self.objects addObject:path];
}


- (void)import
{
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kPaths]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [self parseAndAddLocations:responseArray toArray:self.objects];
        }else{
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }];
    [dataTask resume];
}

- (void)parseAndAddLocations:(NSArray*)paths toArray:(NSMutableArray*)destinationArray
{
    for (NSDictionary* item in paths) {
        Path* path = [[Path alloc] initWithDictionary:item];
        [destinationArray addObject:path];
    }
    if (self.delegate) {
        [self.delegate modelUpdated];
    }
}

- (void) runQuery:(NSString *)queryString
{
    NSString* urlStr = [[kBaseURL stringByAppendingPathComponent:kPaths] stringByAppendingString:queryString];
    NSURL* url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            [self.objects removeAllObjects]; //2
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSLog(@"received %lu items", (unsigned long)responseArray.count);
            [self parseAndAddLocations:responseArray toArray:self.objects];
        }
    }];
    [dataTask resume];
}

- (void) queryRegion:(MKCoordinateRegion)region
{
    //not assumes the NE hemisphere. This logic should really check first.
    //also note that searches across hemisphere lines are not interpreted properly by Mongo
    CLLocationDegrees x0 = region.center.longitude - region.span.longitudeDelta; //2
    CLLocationDegrees x1 = region.center.longitude + region.span.longitudeDelta;
    CLLocationDegrees y0 = region.center.latitude - region.span.latitudeDelta;
    CLLocationDegrees y1 = region.center.latitude + region.span.latitudeDelta;
    
    NSString* boxQuery = [NSString stringWithFormat:@"{\"$geoWithin\":{\"$box\":[[%f,%f],[%f,%f]]}}",x0,y0,x1,y1]; //3
    NSString* locationInBox = [NSString stringWithFormat:@"{\"location\":%@}", boxQuery]; //4
    NSString* escBox = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                             (CFStringRef) locationInBox,
                                                                                             NULL,
                                                                                             (CFStringRef) @"!*();':@&=+$,/?%#[]{}",
                                                                                             kCFStringEncodingUTF8)); //5
    NSString* query = [NSString stringWithFormat:@"?query=%@", escBox]; //6
    [self runQuery:query]; //7
}


- (void) persist:(Path*)path
{
    if (!path || path.categories == nil || path.tags == nil) {
        NSLog(@"!Location");
        return; //input safety check
    }
    
    
    NSString* paths = [kBaseURL stringByAppendingPathComponent:kPaths];
    
    BOOL isExistingLocation = path._id != nil;
    NSURL* url = isExistingLocation ? [NSURL URLWithString:[paths stringByAppendingPathComponent:path._id]] :
    [NSURL URLWithString:paths];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = isExistingLocation ? @"PUT" : @"POST";
    NSData* data = [NSJSONSerialization dataWithJSONObject:[path toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddLocations:responseArray toArray:self.objects];
        } else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [dataTask resume];
}

@end
