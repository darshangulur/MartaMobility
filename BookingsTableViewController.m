//
//  BookingsTableViewController.m
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/28/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import "BookingsTableViewController.h"
#import "BookingsTableViewCell.h"
#import "DataManager.h"
#import "Booking.h"
#import "MBProgressHUD.h"
#import "MapViewController.h"

@interface BookingsTableViewController ()
{
    NSTimer *timer;
    BOOL firstLoad;
}
@property (strong, nonatomic) NSMutableArray *bookingsArray;
@property (strong, nonatomic) NSString* etaValue;

@end

@implementation BookingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    [self performSelector:@selector(stopProgressHUD) withObject:nil afterDelay:1.0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    firstLoad = TRUE;
    self.etaValue = @"";
    [self handleNavigationBarButtons];
    [self loadBookings];
    
    // self.bookingsArray = [[NSMutableArray alloc] initWithObjects:@"A", @"B", @"C", nil];
}

- (void)handleNavigationBarButtons {
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *bookTripButton = [[UIBarButtonItem alloc] initWithTitle:@"Book" style:UIBarButtonItemStyleDone target:self action:@selector(bookATrip)];
    self.navigationItem.leftBarButtonItem = bookTripButton;
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logoutButtonTapped)];
    self.navigationItem.rightBarButtonItem = logoutButton;
}

- (void)loadBookings {
    [[DataManager sharedManager] listOfBookings:^(NSArray *bookings, NSError *error) {
        if (error == nil) {
            self.bookingsArray = [bookings mutableCopy];
            [self.tableView reloadData];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                             target:self
                                           selector:@selector(loadBookings)
                                           userInfo:nil
                                            repeats:NO];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"We're sorry" message:@"We couldn't retrieve your bookings data." preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)logoutButtonTapped {
    [self.navigationController popToRootViewControllerAnimated:true];
}

- (void)bookATrip {
    [self performSegueWithIdentifier:@"BookViewController" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)stopProgressHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:TRUE];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowMapViewController"]) {
        MapViewController *mapViewController = segue.destinationViewController;
        mapViewController.booking = [self.bookingsArray objectAtIndex:0];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.bookingsArray count] > 0 ? 2 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : [self.bookingsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BookingsTableViewCell *cell;
    Booking *booking = [self.bookingsArray objectAtIndex:indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BookingsFirstTableViewCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.sourceLabel.text = [NSString stringWithFormat:@"%@", booking.pickupAddress];
        cell.destinationLabel.text = [NSString stringWithFormat:@"%@", booking.dropOffAddress];
        cell.scheduledDate.text = [NSString stringWithFormat:@"%@", booking.readyTime];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BookingsTableViewCell" forIndexPath:indexPath];
        
        if (indexPath.row % 2 == 1) {
            cell.backgroundColor = [UIColor lightGrayColor];
            cell.bookingNumber.textColor = [UIColor whiteColor];
            cell.scheduledDate.textColor = [UIColor whiteColor];
        }
        
        cell.scheduledDate.text = [NSString stringWithFormat:@"%@ %@", booking.date, booking.readyTime];
    }
    
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.bookingNumber.text = [NSString stringWithFormat:@"%@", booking.bookingID];
    
    NSString *statusText = @"";
    NSInteger delayInMinutes = 0;
    delayInMinutes = [booking.lateMin integerValue] + 30;
    if ([booking.lateMin integerValue] < 0) {
        if (delayInMinutes > 0) {
            statusText = [NSString stringWithFormat:@"Delayed by %li minutes, ETA %@", delayInMinutes, booking.eta];
            
            if (delayInMinutes < 30) {
                cell.statusLabel.textColor = [UIColor yellowColor];
            } else {
                cell.statusLabel.textColor = [UIColor redColor];
            }
        } else {
            statusText = [NSString stringWithFormat:@"On Time"];
            cell.statusLabel.textColor = [UIColor greenColor];
        }
    } else {
        if (delayInMinutes < 0) {
            delayInMinutes = delayInMinutes * -1;
        }
        statusText = [NSString stringWithFormat:@"Delayed by %li minutes, ETA %@", delayInMinutes, booking.eta];
        if (delayInMinutes < 30) {
            cell.statusLabel.textColor = [UIColor yellowColor];
        } else {
            cell.statusLabel.textColor = [UIColor redColor];
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 0 && ![self.etaValue isEqualToString:booking.eta] && !firstLoad) {
        self.etaValue = booking.eta;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update" message:statusText preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.navigationController presentViewController:alert animated:TRUE completion:nil];
    }
    
    if (indexPath.row == [self.bookingsArray count] - 2) {
        firstLoad = FALSE;
    }
    
    cell.statusLabel.text = [NSString stringWithFormat:@"%@", statusText];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 190;
    } else {
        return 70;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 25)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    [label setTextColor:[UIColor whiteColor]];
    
    if (section == 0) {
        [label setText:@"Now"];
    } else {
        [label setText:@"Upcoming"];
    }
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor darkGrayColor]];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"We're sorry" message:@"Booking has not crossed ready time." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"ShowMapViewController" sender:nil];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
