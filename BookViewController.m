//
//  BookViewController.m
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/28/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import "BookViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface BookViewController () <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UIButton *bookTripButton;
@property (strong, nonatomic) NSArray *validCounties;

@end

@implementation BookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.validCounties = @[@"Clayton", @"Fulton", @"Decab"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 100;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)bookATripTapped:(id)sender {
    [self.sourceTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    CLLocation* eventLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    [self getAddressFromLocation:eventLocation complationBlock:^(NSString * address) {
        if(address) {
            NSLog(@"Address => %@", address);
            self.sourceTextField.text = address;
        }
    }];
}

typedef void(^addressCompletion)(NSString *);

-(void)getAddressFromLocation:(CLLocation *)location complationBlock:(addressCompletion)completionBlock
{
    __block CLPlacemark* placemark;
    __block NSMutableString *address = [NSMutableString string];
    
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
     if (error == nil && [placemarks count] > 0)
         {
         placemark = [placemarks lastObject];
         if (placemark.subThoroughfare) {
             [address appendFormat:@"%@, ", placemark.subThoroughfare];
         }
         
         if (placemark.thoroughfare) {
             [address appendFormat:@"%@, ", placemark.thoroughfare];
         }
         
         if (placemark.locality) {
             [address appendFormat:@"%@, ", placemark.locality];
         }
         
         if (placemark.administrativeArea) {
             [address appendFormat:@"%@", placemark.administrativeArea];
         }
         
         [self.bookTripButton setEnabled:TRUE];
         if (![self.validCounties containsObject:placemark.subAdministrativeArea]) {
             address = [@"Location not in MARTA service area." mutableCopy];
             [self.bookTripButton setEnabled:FALSE];
         }
         
         completionBlock(address);
         }
     }];
}

@end
