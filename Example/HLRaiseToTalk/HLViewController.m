//
//  HLViewController.m
//  HLRaiseToTalk
//
//  Created by Michael Kuck on 03/16/2015.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

#import "HLViewController.h"
#import "HLMotionSensor.h"
#import "HLRaiseToTalkSensor.h"

@implementation HLViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        HLMotionSensor *const motionSensor = [[HLMotionSensor alloc] init];
        [motionSensor enable];
        _raiseToTalkSensor = [[HLRaiseToTalkSensor alloc] initWithDevice:[UIDevice currentDevice]
                motionSensor:motionSensor];

        [[NSNotificationCenter defaultCenter]
                addObserver:self selector:@selector(raiseToTalkStateDidChange:)
                name:HLRaiseToTalkStateDidChangeNotification
                object:self.raiseToTalkSensor];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.raiseToTalkSensor.hasProximitySensor) {
        self.raiseToTalkSensor.enabled = YES;
    } else {
        NSLog(@"Device does not support proximity detection.");
    }
}

- (void)raiseToTalkStateDidChange:(NSNotification *)notification
{
    if ([notification.userInfo[HLRaiseToTalkStateDidChangeNotificationStateKey] boolValue]) {
        NSLog(@"Phone was raised to talk.");
    } else {
        NSLog(@"Phone was put back down.");
    }
}

@end
