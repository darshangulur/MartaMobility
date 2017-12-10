//
//  Process.h
//  ProjectP
//
//  Created by Darshan Gulur Srinivasa on 9/14/16.
//  Copyright © 2016 Park At Vinings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Booking : NSObject
@property (strong, nonatomic) NSString *bookingID;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *readyTime;
@property (strong, nonatomic) NSString *windowEnd;
@property (strong, nonatomic) NSString *pickupAddress;
@property (strong, nonatomic) NSString *dropOffAddress;
@property (strong, nonatomic) NSString *pickupLat;
@property (strong, nonatomic) NSString *dropOffLat;
@property (strong, nonatomic) NSString *pickupLong;
@property (strong, nonatomic) NSString *dropOffLong;
@property (strong, nonatomic) NSString *eta;
@property (strong, nonatomic) NSString *lateMin;

- (instancetype)initWithDictionary:(NSDictionary *)bookingDictionary;
@end
