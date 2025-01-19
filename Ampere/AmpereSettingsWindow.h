//
//  AmpereSettingsWindow.h
//  Ampere
//
//  Created by DF on 1/15/25.
//

#import <Cocoa/Cocoa.h>

@interface AmpereSettingsWindow : NSWindow <NSTextFieldDelegate>
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSPopUpButton *temperatureButton;
@property (strong) IBOutlet NSSwitch *loginSwitch;
@property (strong) IBOutlet NSSwitch *batteryColorSwitch;
@property (strong) IBOutlet NSColorWell *normalColorWell;
@property (strong) IBOutlet NSColorWell *chargingColorWell;
@property (strong) IBOutlet NSColorWell *criticalColorWell;
@property (strong) IBOutlet NSColorWell *lowPowerColorWell;
@property (strong) IBOutlet NSColorWell *textColorWell;
@end
