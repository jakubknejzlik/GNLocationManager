//
//  GWUserSession.h
//  GraffitiWalls
//
//  Created by Jakub Knejzlík on 28.06.12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


extern NSString * __nonnull const kGNLocationManagerAuthorizationStatusDidUpdateNotification;
extern NSString * __nonnull const kGNLocationManagerAuthorizationStatusNotificationKey;


NS_ASSUME_NONNULL_BEGIN

@protocol GNLocationObserver;

@interface GNLocationManager : NSObject<CLLocationManagerDelegate>

@property (nullable,nonatomic,readonly) CLLocation *currentLocation;

@property (nonatomic,readonly) CLAuthorizationStatus authorizationStatus;

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

-(void)currentLocationWithCompletionHandler:(void (^)(CLLocation * __nullable currentLocation,NSError * __nullable error))completionHandler;
-(void)currentLocationForced:(BOOL)forced withCompletionHandler:(void (^)(CLLocation * __nullable currentLocation,NSError * __nullable error))completionHandler;

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

NS_ASSUME_NONNULL_END