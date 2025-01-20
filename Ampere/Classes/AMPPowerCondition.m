//
//  AMPPowerCondition.m
//  Ampere
//
//  Created by DF on 1/20/25.
//

#import "AMPPowerCondition.h"

static NSUInteger PowerChangeListenerCount = 0;
static CFRunLoopSourceRef PowerChangeSource = NULL;
static void PowerChangeCallback(void *context) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPowerConditionChangedNotification object:nil];
}

@implementation AMPPowerCondition
- (void)startMonitoringCondition {
    if (!listening) {
        if (PowerChangeListenerCount++==0) {
            
            PowerChangeSource = IOPSNotificationCreateRunLoopSource(PowerChangeCallback,NULL);
            CFRunLoopAddSource([[NSRunLoop mainRunLoop] getCFRunLoop],PowerChangeSource,kCFRunLoopCommonModes);
            }
        listening = YES;
    }
}
- (void)stopMonitoringCondition {
    if (listening) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (--PowerChangeListenerCount==0) {
            CFRunLoopRemoveSource([[NSRunLoop mainRunLoop] getCFRunLoop],PowerChangeSource,kCFRunLoopCommonModes);
            CFRelease(PowerChangeSource);
            PowerChangeSource = NULL;
            listening = NO;
        }
    }
}
@end
