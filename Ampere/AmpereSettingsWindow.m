//
//  AmpereSettingsWindow.m
//  Ampere
//
//  Created by DF on 1/15/25.
//

#import "AmpereSettingsWindow.h"
#import <ServiceManagement/ServiceManagement.h>

#define kPowerConditionChangedNotification  @"AmperePowerConditionChanged"

NSUserDefaults *defaults;

@implementation AmpereSettingsWindow
- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadPreferences];
}
- (void)loadPreferences {
    if (!defaults) defaults = [NSUserDefaults standardUserDefaults];
    
    if (@available(macOS 13.0, *)) {
        BOOL launchesAtLogin = [[SMAppService mainAppService] status] == SMAppServiceStatusEnabled;
        self.loginSwitch.state = (NSControlStateValue)launchesAtLogin;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSArray *jobs = (__bridge NSArray *)SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
        #pragma clang diagnostic pop
        
        BOOL launchesAtLogin = NO;
        if (jobs || [jobs count]>0) {
            for (NSDictionary *job in jobs) {
                if ([[job objectForKey:@"Label"] isEqualToString:@"com.mtac.ampere"]) {
                    launchesAtLogin = [[job objectForKey:@"OnDemand"] boolValue];
                    break;
                }
            }
        }
        
        self.loginSwitch.state = (NSControlStateValue)launchesAtLogin;
    }
    
    BOOL useFahrenheit = [[defaults objectForKey:@"useFahrenheit"] boolValue];
    BOOL useBatteryColors = [[defaults objectForKey:@"useBatteryColors"] boolValue];
    [self.temperatureButton selectItemAtIndex:(useFahrenheit) ? 0 : 1];
    
    [self.batteryColorSwitch setState:(NSControlStateValue)useBatteryColors];
    
    [self setColorElementsEnabled:useBatteryColors];
    
    self.normalColorWell.color = [self colorFromHexString:[defaults objectForKey:@"normalColor"]];
    self.chargingColorWell.color = [self colorFromHexString:[defaults objectForKey:@"chargingColor"]];
    self.criticalColorWell.color = [self colorFromHexString:[defaults objectForKey:@"criticalColor"]];
    self.lowPowerColorWell.color = [self colorFromHexString:[defaults objectForKey:@"lowPowerColor"]];
    self.textColorWell.color = [self colorFromHexString:[defaults objectForKey:@"textColor"]];
}
- (IBAction)temperatureUnitChanged:(NSMenuItem *)sender {
    NSInteger selectedIndex = [self.temperatureButton indexOfItem:sender];
    [self.temperatureButton selectItemAtIndex:selectedIndex];
    [defaults setObject:@((selectedIndex == 0) ? YES : NO) forKey:@"useFahrenheit"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPowerConditionChangedNotification object:nil];
}
- (IBAction)batteryColorSwitchChanged:(NSSwitch *)sender {
    [self setColorElementsEnabled:(BOOL)sender.state];
    [defaults setObject:[NSNumber numberWithBool:sender.state] forKey:@"useBatteryColors"];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPowerConditionChangedNotification object:nil];
}
- (IBAction)toggleAutoLaunch:(NSSwitch *)sender {
    NSError *err;
    if (@available(macOS 13.0, *)) {
        SMAppService *mainService = [SMAppService mainAppService];
        
        if (sender.state == NSControlStateValueOn) {
            [mainService registerAndReturnError:&err];
        } else if (sender.state == NSControlStateValueOff) {
            [mainService unregisterAndReturnError:&err];
        }
    } else {
        SMLoginItemSetEnabled((__bridge CFStringRef)@"com.mtac.ampere", sender.state);
    }
    if (err) {
        NSLog(@"Error -> %@", err);
    }
}
- (IBAction)colorWellDidSelectColor:(NSColorWell *)sender {
    if ([sender isEqual:self.normalColorWell]) {
        NSString *normalColorString = [self hexStringFromColor:self.normalColorWell.color];
        [defaults setObject:normalColorString forKey:@"normalColor"];
    } else if ([sender isEqual:self.chargingColorWell]) {
        NSString *chargingColorString = [self hexStringFromColor:self.chargingColorWell.color];
        [defaults setObject:chargingColorString forKey:@"chargingColor"];
    } if ([sender isEqual:self.criticalColorWell]) {
        NSString *criticalColorString = [self hexStringFromColor:self.criticalColorWell.color];
        [defaults setObject:criticalColorString forKey:@"criticalColor"];
    } if ([sender isEqual:self.lowPowerColorWell]) {
        NSString *lowPowerColorString = [self hexStringFromColor:self.lowPowerColorWell.color];
        [defaults setObject:lowPowerColorString forKey:@"lowPowerColor"];
    } if ([sender isEqual:self.textColorWell]) {
        NSString *textColorString = [self hexStringFromColor:self.textColorWell.color];
        [defaults setObject:textColorString forKey:@"textColor"];
    }
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPowerConditionChangedNotification object:nil];
}
- (void)setColorElementsEnabled:(BOOL)enabled {
    NSArray *colorElements = @[self.chargingColorWell, self.normalColorWell, self.criticalColorWell, self.textColorWell];
    for (NSControl *control in colorElements) {
        [control setEnabled:enabled];
    }
}
- (NSString *)hexStringFromColor:(NSColor *)color {
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    CGFloat red, green, blue, alpha;
    [rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
                lround(red * 255),
                lround(green * 255),
                lround(blue * 255),
                lround(alpha * 255)];
}
- (NSColor *)colorFromHexString:(NSString *)hexString {
    NSString *cleanHexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
        
    if (cleanHexString.length != 6 && cleanHexString.length != 8) {
        NSLog(@"Invalid hex string: %@", hexString);
        return nil;
    }
        
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:cleanHexString] scanHexInt:&rgbValue];
        
    CGFloat red, green, blue, alpha;
    if (cleanHexString.length == 6) {
        red = ((rgbValue >> 16) & 0xFF) / 255.0;
        green = ((rgbValue >> 8) & 0xFF) / 255.0;
        blue = (rgbValue & 0xFF) / 255.0;
        alpha = 1.0;
    } else {
        red = ((rgbValue >> 24) & 0xFF) / 255.0;
        green = ((rgbValue >> 16) & 0xFF) / 255.0;
        blue = ((rgbValue >> 8) & 0xFF) / 255.0;
        alpha = (rgbValue & 0xFF) / 255.0;
    }
    
    return [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end
