//
//  ViewController.m
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/28/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import "LoginViewController.h"
#import <MapKit/MapKit.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CLLocationCoordinate2D storeLocation = CLLocationCoordinate2DMake(33.777948, -84.389500);
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    [self.mapView setRegion:MKCoordinateRegionMake(storeLocation, span) animated:YES];
    [self.mapView setUserInteractionEnabled:false];
    
    [self.usernameTextField.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.usernameTextField.layer setBorderWidth:3.0f];
    
    [self.passwordTextField.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.passwordTextField.layer setBorderWidth:3.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.usernameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonTapped:(id)sender {
    [sender resignFirstResponder];
}
@end
