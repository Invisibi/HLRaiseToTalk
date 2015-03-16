//
//  IVSensor.h
//  Hedwig
//
//  Created by Freddie Wang on 2014/3/21.
//  Copyright (c) 2014年 invisibi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

extern NSString *const kHLMotionSensorUpdateNotification;

typedef struct _Coordinate3D
{
    double x;
    double y;
    double z;
} Coordinate3D;

@interface HLMotionSensor : NSObject

- (BOOL)enable;
- (void)disable;

@property (nonatomic, readonly, assign) BOOL available;
@property (nonatomic, readonly, assign) BOOL activated;
@property (nonatomic, readonly, assign) Coordinate3D currentRotationDegree;
@property (nonatomic, readonly, assign) Coordinate3D currentRotationRate;
@property (nonatomic, readonly, assign) Coordinate3D currentAcceleration;

@end
