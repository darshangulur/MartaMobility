//
//  BookingsTableViewCell.h
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/28/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookingsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bookingNumber;
@property (weak, nonatomic) IBOutlet UILabel *scheduledDate;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;

@end
