//
//  PointsOfInterestTableViewController.m
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 2/25/17.
//  Copyright © 2017 Marta. All rights reserved.
//

#import "PointsOfInterestTableViewController.h"
#import "DataManager.h"
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>

@interface PointsOfInterestTableViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
{
    CLLocation* myLocation;
}

@property (strong, nonatomic) NSArray *pointsOfInterest;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *region;
@end

@implementation PointsOfInterestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"2f234454-cf6d-4a0f-adf2-f4911ba9ffa6"] identifier:@"MARTAmobility"];
    [self.locationManager startRangingBeaconsInRegion:self.region];
    
    self.locationManager.distanceFilter = 100;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    myLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLRegion *)region
{
    if ([beacons count])
    {
    NSNumber *closestBeaconIndex = [NSNumber numberWithDouble:-1];
    CLLocationAccuracy closestKnownBeaconDistance = 50.0;
    for (CLBeacon *beacon in beacons) {
        if (beacon.accuracy < closestKnownBeaconDistance) {
            closestKnownBeaconDistance = beacon.accuracy;
            closestBeaconIndex = beacon.minor;
        }
    }
    
    /*if (closestBeaconIndex.integerValue == 1) {
        self.view.backgroundColor = [UIColor blueColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }*/
    
        [self.locationManager stopRangingBeaconsInRegion:self.region];
        [self getPointsOfInterest];
    }
}

- (void)getPointsOfInterest
{
    [[DataManager sharedManager] listOfPointsOfInterest:^(NSArray *pointsOfInterest, NSError *error) {
        self.pointsOfInterest = pointsOfInterest;
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:TRUE];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [self.pointsOfInterest count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PointOfInterestTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self.pointsOfInterest[indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *location = [[self.pointsOfInterest[indexPath.row] objectForKey:@"geometry"] objectForKey:@"location"];
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", myLocation.coordinate.latitude, myLocation.coordinate.longitude, [[location objectForKey:@"lat"] doubleValue], [[location objectForKey:@"lng"] doubleValue]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    NSDictionary *location = [[self.pointsOfInterest[indexPath.row] objectForKey:@"geometry"] objectForKey:@"location"];
    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=&daddr=%f,%f", [[location objectForKey:@"lat"] doubleValue], [[location objectForKey:@"lng"] doubleValue]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
}


@end
