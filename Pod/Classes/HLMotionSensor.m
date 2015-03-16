//
//  IVSensor.m
//  Hedwig
//
//  Created by Freddie Wang on 2014/3/21.
//  Copyright (c) 2014年 invisibi. All rights reserved.
//

#import "HLMotionSensor.h"

static const unsigned int kSensorUpdateIntervalPerSecond = 100;
static const unsigned int kFloatRounddownPrecision = 10; //10 means 0.x

static const char *kNameOfDispatchQueue = "com.invisibi.sensor";

NSString *const kHLMotionSensorUpdateNotification = @"kHLMotionSensorUpdateNotification";

double correctNegativeZero(double value);

@interface HLMotionSensor ()

@property (nonatomic, readonly, strong) CMMotionManager *motionManager;
@property (nonatomic, readonly, strong) dispatch_queue_t serialQueue;

@property (nonatomic, readwrite, assign) Coordinate3D currentRotationDegree;
@property (nonatomic, readwrite, assign) Coordinate3D currentRotationRate;
@property (nonatomic, readwrite, assign) Coordinate3D currentAcceleration;

@end

@implementation HLMotionSensor

#pragma mark - Life cycle

- (id)init
{
    if (self = [super init]) {
        _motionManager = [[CMMotionManager alloc] init];
        _serialQueue = dispatch_queue_create(kNameOfDispatchQueue, 0);
        return self;
    }
    return nil;
}

- (void)dealloc
{
    [self disable];
}

#pragma mark - Public Implementation

- (BOOL)enable
{
    if (self.available) {
        if (!self.activated) {
            self.motionManager.deviceMotionUpdateInterval = 1.0f / kSensorUpdateIntervalPerSecond;
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new]
                                                    withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                        if (error.code) {
                                                            NSLog(@"Error %zd occured when retrieving motion sensor data: %@", error.code,
                                                                    [error description]);
                                                        } else {
                                                            dispatch_sync(self.serialQueue, ^{
                                                                [self motionDidUpdate:motion];
                                                            });
                                                        }
                                                    }];
        }
        NSLog(@"Motion sensor is activated");
        return YES;
    } else {
        NSLog(@"Motions sensor is not available.");
        return NO;
    }
}

- (void)disable
{
    [self.motionManager stopDeviceMotionUpdates];
    NSLog(@"Motion sensor disabled");
}

- (BOOL)available
{
    return self.motionManager.deviceMotionAvailable;
}

- (BOOL)activated
{
    return self.motionManager.deviceMotionActive;
}

#pragma mark - Private Implementation

- (void)motionDidUpdate:(CMDeviceMotion *)motion
{
    self.currentRotationRate = [self coordinateFromSmoothedMotionValuesX:motion.rotationRate.x y:motion.rotationRate.y
                                                                       z:motion.rotationRate.y];

    self.currentRotationDegree = [self coordinateFromSmoothedMotionValuesX:motion.attitude.pitch y:motion.attitude.roll
                                                                         z:motion.attitude.yaw];

    self.currentAcceleration = [self coordinateFromSmoothedMotionValuesX:motion.userAcceleration.x
                                                                       y:motion.userAcceleration.y z:motion.userAcceleration.z];

#ifdef ENABLE_DEVICE_MOTION_LOG
        LogV(LogCurrentLine, self.description);
#endif

    [[NSNotificationCenter defaultCenter]
            postNotificationName:kHLMotionSensorUpdateNotification object:self userInfo:nil];
}

- (Coordinate3D)coordinateFromSmoothedMotionValuesX:(double)x y:(double)y z:(double)z
{
    double const smoothedX = [self smoothedMotionValue:x];
    double const smoothedY = [self smoothedMotionValue:y];
    double const smoothedZ = [self smoothedMotionValue:z];
    const Coordinate3D coordinate3D = (Coordinate3D) {smoothedX, smoothedY, smoothedZ};
    return coordinate3D;
}

- (double)smoothedMotionValue:(double)motionValue
{
    return correctNegativeZero(round(motionValue * kFloatRounddownPrecision) / kFloatRounddownPrecision);
}

- (NSString *)description
{
    NSString *const rotationRateDescription = [NSString stringWithFormat:@"rotationRate: x=%f, y=%f, z=%f", self.currentRotationRate.x, self.currentRotationRate.y, self.currentRotationRate.z];
    NSString *const rotationDegreeDescription = [NSString stringWithFormat:@"rotationDegree: x=%f, y=%f, z=%f", self.currentRotationDegree.x, self.currentRotationDegree.y, self.currentRotationDegree.z];
    NSString *const accelerationDescription = [NSString stringWithFormat:@"acceleration: x=%f, y=%f, z=%f", self.currentAcceleration.x, self.currentAcceleration.y, self.currentAcceleration.z];
    NSString *const description = [NSString stringWithFormat:@"%@, %@, %@", rotationRateDescription, rotationDegreeDescription, accelerationDescription];
    return description;
}

#pragma mark - Util

double correctNegativeZero(double value) {
    if (value == -0.0)
        value = 0.0;

    return value;
}

@end
