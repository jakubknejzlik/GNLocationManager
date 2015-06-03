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
@property (nullable,nonatomic,readonly) CLLocation *currentLocation;
/** Maximum timeout until location is marked as invalid. Used when validating current location and location for observers. */
@property (nonatomic) NSTimeInterval locationValidMaxTimeout;
/** Minimum timeout to enable location refresh when new is detected. Used when validating current location and location for observers. */
@property NSTimeInterval locationRefreshMinTimeout;
/** Minimum distance to enable location refresh when new is detected. Used when validating location for observers. */
@property CLLocationDistance locationRefreshMinDistance;

+(nullable GNLocationManager *)sharedInstance;

+(BOOL)locationServicesEnabled;

-(void)requestAuthorization;

-(void)invalidateCurrentLocation;

-(void)currentLocationWithCompletionHandler:(void (^ __nonnull)(CLLocation * __nullable currentLocation,NSError * __nullable error))completionHandler;
-(void)currentLocationForced:(BOOL)forced withCompletionHandler:(void (^ __nonnull)(CLLocation * __nullable currentLocation,NSError * __nullable error))completionHandler;

-(void)addLocationObserver:(id<GNLocationObserver> __nonnull )observer;
-(void)removeLocationObserver:(id<GNLocationObserver>  __nonnull )observer;


@end




@protocol GNLocationObserver <NSObject>
-(void)locationManager:(GNLocationManager * __nonnull)locationManager didUpdateCurrentLocation:(CLLocation * __nonnull)currentLocation;

@optional
-(void)locationManager:(GNLocationManager * __nonnull)locationManager didFailWithError:(NSError * __nonnull)error;
-(NSTimeInterval)locationValidMaxTimeout:(GNLocationManager * __nonnull)locationManager;
-(NSTimeInterval)locationRefreshMinTimeout:(GNLocationManager * __nonnull)locationManager;
-(CLLocationDistance)locationRefreshMinDistance:(GNLocationManager * __nonnull)locationManager;

@end

