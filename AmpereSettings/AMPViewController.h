//
//  AMPViewController.h
//  AmpereSettings
//
//  Created by DF on 1/19/25.
//

#import <Cocoa/Cocoa.h>
#import "ITSwitch.h"

@interface AMPViewController : NSViewController
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSSegmentedControl *segmentControl;
@property (strong) IBOutlet NSButton *temperatureButton;
@property (strong) IBOutlet NSButton *styleButton;
@property (strong) IBOutlet NSButton *fontButton;
@property (strong) IBOutlet NSMenu *temperatureMenu;
@property (strong) IBOutlet NSMenu *styleMenu;
@property (strong) NSMenu *fontMenu;
@property (strong) IBOutlet ITSwitch *loginSwitch;
@property (strong) IBOutlet ITSwitch *percentageSwitch;
@property (strong) IBOutlet ITSwitch *batteryColorSwitch;
@property (strong) IBOutlet NSColorWell *normalColorWell;
@property (strong) IBOutlet NSColorWell *chargingColorWell;
@property (strong) IBOutlet NSColorWell *criticalColorWell;
@property (strong) IBOutlet NSColorWell *lowPowerColorWell;
@property (strong) IBOutlet NSColorWell *textColorWell;
@property (strong) IBOutlet NSTextField *versionLabel;
@end

