//
//  AMPPowerCondition.h
//  Ampere
//
//  Created by DF on 1/20/25.
//

#import <Foundation/Foundation.h>
#import <IOKit/ps/IOPowerSources.h>

#define kPowerConditionChangedNotification  @"AmperePowerConditionChanged"

@interface AMPPowerCondition : NSObject {
    BOOL listening;
}
- (void)startMonitoringCondition;
- (void)stopMonitoringCondition;
@end
