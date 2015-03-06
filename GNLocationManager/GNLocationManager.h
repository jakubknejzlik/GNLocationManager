//
//  GWUserSession.h
//  GraffitiWalls
//
//  Created by Jakub Knejzlík on 28.06.12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GNLocationObserver;

@interface GNLocationManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic,readonly) CLLocation *currentLocation;
/** Maximum timeout until location is marked as invalid. Used when validating current location and location for observers. */
@property (nonatomic) NSTimeInterval locationValidMaxTimeout;
/** Minimum timeout to enable location refresh when new is detected. Used when validating current location and location for observers. */
@property NSTimeInterval locationRefreshMinTimeout;
/** Minimum distance to enable location refresh when new is detected. Used when validating location for observers. */
@property CLLocationDistance locationRefreshMinDistance;

+(GNLocationManager *)sharedInstance;

-(void)invalidateCurrentLocation;

-(void)currentLocationWithCompletionHandler:(void (^)(CLLocation *currentLocation,NSError *error))completionHandler;
-(void)currentLocationForced:(BOOL)forced withCompletionHandler:(void (^)(CLLocation *currentLocation,NSError *error))completionHandler;

-(void)addLocationObserver:(id<GNLocationObserver>)observer;
-(void)removeLocationObserver:(id<GNLocationObserver>)observer;


@end




@protocol GNLocationObserver <NSObject>
-(void)locationManager:(GNLocationManager *)locationManager didUpdateCurrentLocation:(CLLocation *)currentLocation;

@optional
-(void)locationManager:(GNLocationManager *)locationManager didFailWithError:(NSError *)error;
-(NSTimeInterval)locationValidMaxTimeout:(GNLocationManager *)locationManager;
-(NSTimeInterval)locationRefreshMinTimeout:(GNLocationManager *)locationManager;
-(CLLocationDistance)locationRefreshMinDistance:(GNLocationManager *)locationManager;

@end

