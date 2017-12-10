//
//  DataManager.h
//  ProjectP
//
//  Created by Darshan Gulur Srinivasa on 8/22/16.
//  Copyright © 2016 Park At Vinings. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
+ (instancetype)sharedManager;
- (void)listOfBookings:(void (^)(NSArray *projects, NSError *error))block;
- (void)listOfPositions:(void (^)(NSArray *positions, NSError *error))block;
- (void)listOfPointsOfInterest:(void (^)(NSArray *pointsOfInterest, NSError *error))block;
@end
