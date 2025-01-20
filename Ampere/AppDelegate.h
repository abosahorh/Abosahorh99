//
//  AppDelegate.h
//  Ampere
//
//  Created by DF on 1/9/25.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <ServiceManagement/ServiceManagement.h>
#import "Classes/AMPTextFieldCell.h"
#import "Classes/AMPPowerCondition.h"

extern NSString *const kCAFilterDestOut;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (readwrite, retain) IBOutlet NSStatusItem *statusItem;
@property (strong, retain) IBOutlet NSView *batteryMenuView;
@property (nonatomic, strong) IBOutlet NSMenu *batteryMenu;
@property (nonatomic, retain) IBOutlet NSTextField *sourceLabel;
@property (nonatomic, retain) IBOutlet NSTextField *cycleLabel;
@property (nonatomic, retain) IBOutlet NSTextField *healthLabel;
@property (nonatomic, retain) IBOutlet NSTextField *capacityLabel;
@property (nonatomic, retain) IBOutlet NSTextField *temperatureLabel;
@property (nonatomic, retain) IBOutlet NSTextField *amperageLabel;
@property (nonatomic, retain) IBOutlet NSTextField *voltageLabel;
@property (nonatomic, retain) IBOutlet NSTextField *powerLabel;
@property (nonatomic, retain) NSTextField *percentageLabel;
@property (atomic, assign) BOOL launchOnLogin;
@property (nonatomic, retain) NSLayoutConstraint *labelHeightConstraint;
@property (nonatomic, retain) NSLayoutConstraint *labelCenterConstraint;
@property (nonatomic, retain) NSLayoutConstraint *labelTrailingConstraint;
@end

@interface CALayer (BetterCC)
@property BOOL allowsGroupBlending;
@end

