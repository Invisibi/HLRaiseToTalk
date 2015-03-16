//
//  HLViewController.h
//  HLRaiseToTalk
//
//  Created by Michael Kuck on 03/16/2015.
//  Copyright (c) 2014 Michael Kuck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLRaiseToTalkSensor;

@interface HLViewController : UIViewController

@property (nonatomic, readonly) HLRaiseToTalkSensor *raiseToTalkSensor;
@end
