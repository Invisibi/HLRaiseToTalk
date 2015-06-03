//
//  IVProximitySensor.m
//  Hedwig
//
//  Created by Ken Kuan on 5/26/14.
//  Copyright (c) 2014 invisibi. All rights reserved.
//

#import "HLRaiseToTalkSensor.h"

#import "HLMotionSensor.h"

NSString *const HLRaiseToTalkStateDidChangeNotification = @"HLRaiseToTalkStateDidChangeNotification";
NSString *const HLRaiseToTalkStateDidChangeNotificationStateKey = @"HLRaiseToTalkStateDidChangeNotificationStateKey";

static const CGFloat kIVProximityRotationRateThreshold = 1.1f;
static const CGFloat kIVProximityAccelerationThreshold = 0.11f;

@interface HLRaiseToTalkSensor ()

@property (nonatomic) UIDevice *device;
@property (nonatomic) NSTimeInterval lastProximityChangeTime;
@property (nonatomic) NSTimer *disableProximityTimer;
@property (nonatomic) NSTimer *changeStateTimer;
@property (nonatomic) double avgRotationRate;
@property (nonatomic) double avgAcceleration;
@property (nonatomic) HLMotionSensor *motionSensor;

@end

@implementation HLRaiseToTalkSensor

- (instancetype)initWithDevice:(UIDevice *)device motionSensor:(HLMotionSensor *)motionSensor
{
    self = [super init];
    if (self) {
        _device = device;
        // Initialize with motion instead of no motion(=0) to enable proximity sensor when starting the app
        _avgRotationRate = 0.0f;
        _avgAcceleration = 0.0f;
        _enabled = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:device];
        [[NSNotificationCenter defaultCenter]
                addObserver:self selector:@selector(motionSensorValueUpdate:) name:kHLMotionSensorUpdateNotification
                object:motionSensor];
        self.motionSensor = motionSensor;
    }
    return self;
}

- (void)dealloc
{
    [self.motionSensor disable];
    [self stopDisableProximitySensorTimer];
    self.device.proximityMonitoringEnabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isRaisedToTalk
{
    return self.device.proximityState;
}

- (void)proximityStateChanged:(NSNotification *)notification
{
    UIDevice *device = notification.object;
    [[NSNotificationCenter defaultCenter] postNotificationName:HLRaiseToTalkStateDidChangeNotification object:self
            userInfo:@{HLRaiseToTalkStateDidChangeNotificationStateKey : @(device.proximityState)}];
}

- (void)setEnabled:(BOOL)enabled
{
    NSTimeInterval timestamp = CFAbsoluteTimeGetCurrent();
    if (timestamp - self.lastProximityChangeTime > 0.1) {
        if (enabled) {
            [self stopDisableProximitySensorTimer];
            if (!self.device.proximityMonitoringEnabled) {
                self.device.proximityMonitoringEnabled = YES;
            }
        } else {
            [self startDisableProximitySensorTimer];
        }
        self.lastProximityChangeTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)disableProximity
{
    if (self.device.proximityMonitoringEnabled) {
        self.device.proximityMonitoringEnabled = NO;
        [self stopDisableProximitySensorTimer];
        [self.changeStateTimer invalidate];
        self.changeStateTimer = nil;
        NSLog(@"RaiseToTalk monitoring disabled");
    }
}

- (BOOL)hasProximitySensor
{
    // Ken Kuan: Try to enable proximity sensor to detect device has proximity or not
    self.device.proximityMonitoringEnabled = YES;
    if (self.device.proximityMonitoringEnabled) {
        self.device.proximityMonitoringEnabled = NO;
        return YES;
    }
    return NO;
}

- (void)startDisableProximitySensorTimer
{
    if (self.disableProximityTimer == nil) {
        self.disableProximityTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(disableProximity) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.disableProximityTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopDisableProximitySensorTimer
{
    if (self.disableProximityTimer) {
        [self.disableProximityTimer invalidate];
        self.disableProximityTimer = nil;
    }
}

- (void)motionSensorValueUpdate:(NSNotification *)notification
{
    HLMotionSensor *const motionSensor = notification.object;

    const double rotationX = motionSensor.currentRotationRate.x;
    const double rotationY = motionSensor.currentRotationRate.y;
    const double rotationZ = motionSensor.currentRotationRate.z;
    double currentRotationRate = sqrt(rotationX * rotationX + rotationY * rotationY + rotationZ * rotationZ);
    self.avgRotationRate = 0.9 * self.avgRotationRate + 0.1 * currentRotationRate;

    const double accelerationX = motionSensor.currentAcceleration.x;
    const double accelerationY = motionSensor.currentAcceleration.y;
    const double accelerationZ = motionSensor.currentAcceleration.z;
    double currentAcceleration = sqrt(accelerationX * accelerationX + accelerationY * accelerationY + accelerationZ * accelerationZ);
    self.avgAcceleration = 0.9 * self.avgAcceleration + 0.1 * currentAcceleration;

#ifdef ENABLE_DEVICE_MOTION_LOG
    LogV(LogCurrentLine, @"Rotation: (%0.3f, %.3f, %.3f) -> (%0.3f), avg:(%0.3f), Acceleration: (%0.3f, %.3f, %.3f) -> (%0.3f), avg:(%0.3f)",
         rotationX, rotationY, rotationZ, currentRotationRate, self.avgRotationRate,
         accelerationX, accelerationY, accelerationZ, currentAcceleration, self.avgAcceleration);
#endif

    if ((self.avgRotationRate > kIVProximityRotationRateThreshold) && (self.avgAcceleration > kIVProximityAccelerationThreshold)) {
        self.enabled = YES;
    } else {
        if (!self.device.proximityState) {
            self.enabled = NO;
        }
    }
}

@end
