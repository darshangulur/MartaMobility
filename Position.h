//
//  Position.h
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/29/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject
@property (strong, nonatomic) NSString *MSGTIME;
@property (strong, nonatomic) NSString *LATITUDE;
@property (strong, nonatomic) NSString *VEHICLE;
@property (strong, nonatomic) NSString *DIRECTION;
@property (strong, nonatomic) NSString *LONGITUDE;

- (instancetype)initWithDictionary:(NSDictionary *)positionDictionary;
@end
