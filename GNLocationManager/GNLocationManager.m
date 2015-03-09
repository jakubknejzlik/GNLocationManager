//
//  GWUserSession.m
//  GraffitiWalls
//
//  Created by Jakub Knejzlík on 28.06.12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GNLocationManager.h"

#import <CWLSynthesizeSingleton.h>

@interface GNLocationManager ()
@property (nonatomic,strong) CLLocationManager *locationManager;

@property (nonatomic,strong) NSMutableArray *currentLocationRequests;
@property (nonatomic,strong) NSMutableArray *locationObservers;

@property (nonatomic,strong) NSMutableDictionary *observerLocations;

@property BOOL locationManagerIsUpdatingLocation;
@end


@implementation GNLocationManager
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(GNLocationManager,sharedInstance);

@synthesize locationManager = _locationManager,currentLocation = _currentLocation;
@synthesize currentLocationRequests = _currentLocationRequests;

-(id)init{
    self = [super init];
    if (self) {
        self.locationValidMaxTimeout = 30;
        self.locationRefreshMinTimeout = 10;
        self.locationRefreshMinDistance = 5;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])[self.locationManager requestAlwaysAuthorization];
        }else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])[self.locationManager requestWhenInUseAuthorization];
        }else{
            NSLog(@"[ERROR] The keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription are not defined in your tiapp.xml.  Starting with iOS8 this are required.");
        }
    }
    return self;
}


+(BOOL)locationServicesEnabled{
    return [CLLocationManager locationServicesEnabled];
}

-(void)setLocationValidMaxTimeout:(NSTimeInterval)locationValidMaxTimeout{
    if(locationValidMaxTimeout < 2)NSLog(@"GNLocationManager: locationValidMaxTimeout shouldn't be too small (manager will never be able to load new location as it's never will be valid)");
    _locationValidMaxTimeout = locationValidMaxTimeout;
}


-(void)invalidateCurrentLocation{
    _currentLocation = nil;
}


-(void)currentLocationWithCompletionHandler:(void (^)(CLLocation *currentLocation,NSError *error))completionHandler{
    [self currentLocationForced:NO withCompletionHandler:completionHandler];
}
-(void)currentLocationForced:(BOOL)forced withCompletionHandler:(void (^)(CLLocation *currentLocation,NSError *error))completionHandler{
    if([self isCurrentLocationValid] && !forced){
        completionHandler(self.currentLocation,nil);
    }else{
        if(!self.currentLocationRequests)self.currentLocationRequests = [NSMutableArray array];
        [self.currentLocationRequests addObject:[completionHandler copy]];
        [self startUpdatingLocation];
    }
}

-(BOOL)isCurrentLocationValid{
    return [self isLocationValidForSelf:self.currentLocation];
}
-(BOOL)isLocationValidForSelf:(CLLocation *)location{
    return location && [[NSDate date] timeIntervalSinceDate:location.timestamp] < self.locationValidMaxTimeout;
}
-(BOOL)isLocationValid:(CLLocation *)location forObserver:(id<GNLocationObserver>)observer{
    return location && [[NSDate date] timeIntervalSinceDate:location.timestamp] < [self locationValidMaxTimeoutFromObserver:observer];
}
-(BOOL)newLocation:(CLLocation *)newLocation shouldReplaceLocationForObserver:(id<GNLocationObserver>)observer{
    return [self newLocation:newLocation shouldReplaceOldLocation:[self locationForObserver:observer] observer:observer];
}
-(BOOL)newLocation:(CLLocation *)newLocation shouldReplaceOldLocation:(CLLocation *)oldLocation observer:(id<GNLocationObserver>)observer{
    if(!oldLocation)return YES;
    if(![self isLocationValid:newLocation forObserver:observer])return YES;
    if([newLocation distanceFromLocation:oldLocation] > [self locationRefreshMinDistanceFromObserver:observer])return YES;
    if([oldLocation.timestamp timeIntervalSinceDate:newLocation.timestamp] > [self locationRefreshMinTimeoutFromObserver:observer])return YES;
    return NO;
}


#pragma mark - Observers
-(void)addLocationObserver:(id<GNLocationObserver>)observer{
    if (!self.locationObservers) {
        self.locationObservers = [NSMutableArray array];
    }
    [self.locationObservers addObject:[NSValue valueWithNonretainedObject:observer]];
    [self startUpdatingLocation];
}
-(void)removeLocationObserver:(id<GNLocationObserver>)observer{
    for (NSValue *p in [self.locationObservers copy]) {
        if([p nonretainedObjectValue] == observer)[self.locationObservers removeObject:p];
    }
    [self stopUpdatingLocationIfShould];
}
-(void)notifyObserversWithNewLocation:(CLLocation *)location{
    for (NSValue *p in self.locationObservers) {
        id<GNLocationObserver> observer = [p nonretainedObjectValue];
        if([self newLocation:location shouldReplaceLocationForObserver:observer]){
            [self setLocation:location forObserver:observer];
            [observer locationManager:self didUpdateCurrentLocation:location];
        }
    }
}
-(void)notifyObserversWithError:(NSError *)error{
    for (NSValue *p in self.locationObservers) {
        id<GNLocationObserver> observer = [p nonretainedObjectValue];
        if([observer respondsToSelector:@selector(locationManager:didFailWithError:)])
            [observer locationManager:self didFailWithError:error];
    }
}
-(NSTimeInterval)locationRefreshMinTimeoutFromObserver:(id<GNLocationObserver>)observer{
    if([observer respondsToSelector:@selector(locationRefreshMinTimeout:)])return [observer locationRefreshMinTimeout:self];
    return self.locationRefreshMinTimeout;
}
-(CLLocationDistance)locationRefreshMinDistanceFromObserver:(id<GNLocationObserver>)observer{
    if([observer respondsToSelector:@selector(locationRefreshMinDistance:)])return [observer locationRefreshMinDistance:self];
    return self.locationRefreshMinTimeout;
}
-(NSTimeInterval)locationValidMaxTimeoutFromObserver:(id<GNLocationObserver>)observer{
    if([observer respondsToSelector:@selector(locationValidMaxTimeout:)])return [observer locationValidMaxTimeout:self];
    return self.locationValidMaxTimeout;
}

-(void)setLocation:(CLLocation *)location forObserver:(id<GNLocationObserver>)observer{
    if(!self.observerLocations)self.observerLocations = [NSMutableDictionary dictionary];
    [self.observerLocations setObject:location forKey:[NSValue valueWithNonretainedObject:observer]];
}
-(void)removeLocationForObserver:(id<GNLocationObserver>)observer{
    [self.observerLocations removeObjectForKey:[NSValue valueWithNonretainedObject:observer]];
}
-(CLLocation *)locationForObserver:(id<GNLocationObserver>)observer{
    return [self.observerLocations objectForKey:[NSValue valueWithNonretainedObject:observer]];
}



#pragma mark - LocationManager Delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if([self.currentLocationRequests count] > 0){
        for(void (^completionHandler)(CLLocation *currentLocation,NSError *error) in self.currentLocationRequests){
            completionHandler(nil,error);
        }
        [self.currentLocationRequests removeAllObjects];
    }
    [self notifyObserversWithError:error];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [self locationManager:manager didUpdateLocations:[NSArray arrayWithObject:newLocation]];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    if([self isLocationValidForSelf:newLocation]){
        _currentLocation = newLocation;
        if([self.currentLocationRequests count] > 0){
            for(void (^completionHandler)(CLLocation *currentLocation,NSError *error) in self.currentLocationRequests){
                completionHandler(self.currentLocation,nil);
            }
            [self.currentLocationRequests removeAllObjects];
        }
    }
    [self notifyObserversWithNewLocation:newLocation];
    [self stopUpdatingLocationIfShould];
}
-(void)startUpdatingLocation{
    if(self.locationManagerIsUpdatingLocation)return;
    [self.locationManager startUpdatingLocation];
    self.locationManagerIsUpdatingLocation = YES;
}
-(BOOL)shouldStopUpdating{
    return ([self.currentLocationRequests count] + [self.locationObservers count] == 0);
}
-(void)stopUpdatingLocationIfShould{
    if([self shouldStopUpdating])[self stopUpdatingLocation];
}
-(void)stopUpdatingLocation{
    if(!self.locationManagerIsUpdatingLocation)return;
    [self.locationManager stopUpdatingLocation];
    self.locationManagerIsUpdatingLocation = NO;
    _currentLocation = nil;
}

@end
