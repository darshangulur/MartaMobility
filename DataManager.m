//
//  DataManager.m
//  ProjectP
//
//  Created by Darshan Gulur Srinivasa on 8/22/16.
//  Copyright © 2016 Park At Vinings. All rights reserved.
//

#import "DataManager.h"
#import "Booking.h"
#import "Position.h"

@implementation DataManager

+ (instancetype)sharedManager
{
    static DataManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)listOfBookings:(void (^)(NSArray *bookings, NSError *error))block
{
    NSURL *url = [NSURL URLWithString:@"http://markthomasnoonan.com/mark/sandbox/marta.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
     if (data.length > 0 && connectionError == nil)
         {
         NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:NULL];
        NSArray *objects = [object objectForKey:@"bookings"];
         __block NSMutableArray *bookings = [[NSMutableArray alloc] init];
         [objects enumerateObjectsUsingBlock:^(NSDictionary *booking, NSUInteger idx, BOOL * _Nonnull stop) {
             [bookings addObject:[[Booking alloc] initWithDictionary:booking]];
         }];
         
         if (block)
             {
             block(bookings, nil);
             }
         else
             {
             block(nil, nil);
             }
         } else
             {
             block(nil, nil);
             }
     }];
}

- (void)listOfBokings:(void (^)(NSArray *bookings, NSError *error))block
{
    NSError *deserializingError;
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"bookings" ofType:@"json"];
    NSData *contentOfLocalFile = [NSData dataWithContentsOfFile:pathToFile];
    id object = [NSJSONSerialization JSONObjectWithData:contentOfLocalFile
                                                options:NSJSONReadingAllowFragments
                                                  error:&deserializingError];
    
    if (object)
        {
        NSArray *objects = [object objectForKey:@"bookings"];
        __block NSMutableArray *bookings = [[NSMutableArray alloc] init];
        [objects enumerateObjectsUsingBlock:^(NSDictionary *booking, NSUInteger idx, BOOL * _Nonnull stop) {
            [bookings addObject:[[Booking alloc] initWithDictionary:booking]];
        }];
        
        if (block)
            {
            block(bookings, nil);
            }
        else
            {
            block(nil, nil);
            }
        }
    else
        {
        block(nil, nil);
        }
}

- (void)listOfPositions:(void (^)(NSArray *positions, NSError *error))block
{
    NSError *deserializingError;
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"vehicledata" ofType:@"json"];
    NSData *contentOfLocalFile = [NSData dataWithContentsOfFile:pathToFile];
    id object = [NSJSONSerialization JSONObjectWithData:contentOfLocalFile
                                                options:NSJSONReadingAllowFragments
                                                  error:&deserializingError];
    
    if (object)
        {
        NSArray *objects = [object objectForKey:@"1602"];
        __block NSMutableArray *positions = [[NSMutableArray alloc] init];
        [objects enumerateObjectsUsingBlock:^(NSDictionary *position, NSUInteger idx, BOOL * _Nonnull stop) {
            [positions addObject:[[Position alloc] initWithDictionary:position]];
        }];
        
        if (block)
            {
            block(positions, nil);
            }
        else
            {
            block(nil, nil);
            }
        }
    else
        {
        block(nil, nil);
        }
}

- (void)listOfPointsOfInterest:(void (^)(NSArray *pointsOfInterest, NSError *error))block
{
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=33.771289,-84.386377&radius=500&type=restaurant&keyword=cruise&key=AIzaSyCMSqsylgB_Z3_CWA2igoz2TwgRrym3j4Q"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
     if (data.length > 0 && connectionError == nil)
         {
         NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:NULL];
         NSArray *objects = [object objectForKey:@"results"];
         /*__block NSMutableArray *bookings = [[NSMutableArray alloc] init];
         [objects enumerateObjectsUsingBlock:^(NSDictionary *booking, NSUInteger idx, BOOL * _Nonnull stop) {
             [bookings addObject:[[Booking alloc] initWithDictionary:booking]];
         }];*/
         
         if (block)
             {
             block(objects, nil);
             }
         else
             {
             block(nil, nil);
             }
         } else
             {
             block(nil, nil);
             }
     }];
}

@end
