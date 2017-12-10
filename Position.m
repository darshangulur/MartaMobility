//
//  Position.m
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/29/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import "Position.h"

@implementation Position
@synthesize MSGTIME;
@synthesize LATITUDE;
@synthesize VEHICLE;
@synthesize DIRECTION;
@synthesize LONGITUDE;

- (instancetype)initWithDictionary:(NSDictionary *)positionDictionary
{
    if (positionDictionary)
    {
        Position *position = [[Position alloc] init];
        position.MSGTIME = [positionDictionary objectForKey:@"MSGTIME"];
        position.LATITUDE = [positionDictionary objectForKey:@"LATITUDE"];
        position.VEHICLE = [positionDictionary objectForKey:@"VEHICLE"];
        position.DIRECTION = [positionDictionary objectForKey:@"DIRECTION"];
        position.LONGITUDE = [positionDictionary objectForKey:@"LONGITUDE"];
        return position;
    }
    
    return nil;
}
@end
