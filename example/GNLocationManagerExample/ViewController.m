//
//  ViewController.m
//  GNLocationManagerExample
//
//  Created by Jakub Knejzlik on 06/03/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "ViewController.h"

#import "GNLocationManager.h"

@interface ViewController () <GNLocationObserver>
@property (nonatomic,strong) IBOutlet UILabel *locationLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GNLocationManager sharedInstance] addLocationObserver:self];
}

-(void)locationManager:(GNLocationManager *)locationManager didUpdateCurrentLocation:(CLLocation *)currentLocation{
    self.locationLabel.text = [currentLocation description];
}

@end
