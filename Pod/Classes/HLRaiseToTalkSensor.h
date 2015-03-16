//
//  IVProximitySensor.h
//  Hedwig
//
//  Created by Ken Kuan on 5/26/14.
//  Copyright (c) 2014 invisibi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HLMotionSensor;

extern NSString *const HLRaiseToTalkStateDidChangeNotification;
extern NSString *const HLRaiseToTalkStateDidChangeNotificationStateKey;

@interface HLRaiseToTalkSensor : NSObject

@property (nonatomic, readonly) BOOL state;
@property (nonatomic, readonly) BOOL hasProximitySensor;

@property (nonatomic) BOOL enabled;

- (instancetype)initWithDevice:(UIDevice *)device motionSensor:(HLMotionSensor *)motionSensor;

@end
