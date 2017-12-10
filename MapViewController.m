//
//  MapViewController.m
//  MARTAmobility
//
//  Created by Darshan Gulur Srinivasa on 10/29/16.
//  Copyright © 2016 Marta. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "DataManager.h"
#import "Position.h"
#import "MBProgressHUD.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *positions;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) MKPlacemark *destination;
@property (strong,nonatomic) MKPlacemark *source;

@property (strong, nonatomic) MKPolyline *routeOverlay;
@property (strong, nonatomic) MKRoute *currentRoute;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    
    UIBarButtonItem *cancelTripButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel Trip" style:UIBarButtonItemStyleDone target:self action:nil];
    self.navigationItem.rightBarButtonItem = cancelTripButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
    [cancelTripButton setTarget:self];
    [cancelTripButton setAction:@selector(cancelButtonTapped)];
    
    self.locationManager.distanceFilter = 100;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    // Do any additional setup after loading the view.
    [self loadPositions];
}

- (void)cancelButtonTapped
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    CLLocation* myLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    [self getDirections:myLocation];
    
}

- (void)loadPositions {
    [[DataManager sharedManager] listOfPositions:^(NSArray *positions, NSError *error) {
        if (error == nil) {
            self.positions = [positions mutableCopy];
            
            self.mapView.delegate = self;
            self.mapView.showsUserLocation = YES;
            // Position *position = [positions objectAtIndex:0];
            
            // [self getDirections:position];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)callMARTATapped:(id)sender {
    NSString *stringURL = @"tel:4703018572";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

-(void)getDirections:(CLLocation *)myLocation {
    
    CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
    
    MKCoordinateRegion region;
    //Set Zoom level using Span
    MKCoordinateSpan span;
    region.center = sourceCoords;
    
    span.latitudeDelta = 0.25;
    span.longitudeDelta = 0.25;
    region.span = span;
    [self.mapView setRegion:region animated:TRUE];
    
    MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
    
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = sourceCoords;
    annotation1.title = @"My Location";
    [self.mapView addAnnotation:annotation1];
    // [self.myMapView addAnnotation:placemark];
    
    self.source = placemark;
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:self.source];
    
    CLLocationCoordinate2D destCoords = CLLocationCoordinate2DMake([self.booking.pickupLat doubleValue], [self.booking.pickupLong doubleValue]);
    MKPlacemark *placemark1  = [[MKPlacemark alloc] initWithCoordinate:destCoords addressDictionary:nil];
    
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = destCoords;
    annotation2.title = self.booking.pickupAddress;
    [self.mapView addAnnotation:annotation2];
    
    //[self.myMapView addAnnotation:placemark1];
    
    self.destination = placemark1;
    
    MKMapItem *mapItem1 = [[MKMapItem alloc] initWithPlacemark:self.destination];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.destination = mapItem1;
    
    request.source = mapItem;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"ERROR");
             NSLog(@"%@", [error localizedDescription]);
         } else {
             // [self showRoute:response];
             
             NSLog(@"response = %@",response);
             NSArray *arrRoutes = [response routes];
             self.currentRoute = [response.routes firstObject];
             [self plotRouteOnMap:self.currentRoute];
             [MBProgressHUD hideHUDForView:self.view animated:TRUE];
         }
     }];
}

/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPointAnnotation *pointAnnotation = annotation;
    MKAnnotationView * annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    if ([pointAnnotation.title isEqualToString:@"San Francisco University"]) {
        annotationView.image = [UIImage imageNamed:@"home.png"];
    } else {
        annotationView.image = [UIImage imageNamed:@"van.png"];
    }
    return annotationView;
}*/

- (void)plotRouteOnMap:(MKRoute *)route
{
    if(self.routeOverlay) {
        [self.mapView removeOverlay:self.routeOverlay];
    }
    
    // Update the ivar
    self.routeOverlay = route.polyline;
    
    // Add it to the map
    [self.mapView addOverlay:self.routeOverlay];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

#pragma mark - MKMapViewDelegate methods
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 4.0;
    return  renderer;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
