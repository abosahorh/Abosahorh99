//
//  AppDelegate.m
//  Ampere
//
//  Created by DF on 1/9/25.
//

#import "AppDelegate.h"
#include <objc/runtime.h>

#define kPowerConditionChangedNotification  @"AmperePowerConditionChanged"

NSUserDefaults *preferences;

static NSUInteger PowerChangeListenerCount = 0;
static CFRunLoopSourceRef PowerChangeSource = NULL;
static void PowerChangeCallback(void *context) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPowerConditionChangedNotification object:nil];
}

BOOL containsKey(NSString *key) {
    return [preferences.dictionaryRepresentation.allKeys containsObject:key];
}

@interface PowerCondition : NSObject {
    BOOL listening;
    //...
}
@end

@implementation PowerCondition
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

@interface AmpereColorWell : NSColorWell
@end

@implementation AmpereColorWell
- (void)activate:(BOOL)exclusive {
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [super activate:exclusive];
}
- (void)deactivate {
    [super deactivate];
    [[NSColorPanel sharedColorPanel] setShowsAlpha:NO];
}
@end

@interface AppDelegate ()
@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize percentageLabel;
- (void)awakeFromNib {
    if (!preferences) preferences = [NSUserDefaults standardUserDefaults];
    [self loadPreferences];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryInfo) name:kPowerConditionChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBatteryInfo) name:NSProcessInfoPowerStateDidChangeNotification object:nil];
    
    PowerCondition *condition = [[PowerCondition alloc] init];
    [condition startMonitoringCondition];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setLength:32];
    [_statusItem.button setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]];
    _statusItem.button.imageScaling = NSImageScaleProportionallyDown;
    _statusItem.menu = self.batteryMenu;
    
    percentageLabel = [[NSTextField alloc] initWithFrame:CGRectZero];
    percentageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    percentageLabel.bezeled = NO;
    percentageLabel.editable = NO;
    percentageLabel.drawsBackground = NO;
    percentageLabel.font = [NSFont systemFontOfSize:11 weight:NSFontWeightBold];
    percentageLabel.backgroundColor = [NSColor clearColor];
    percentageLabel.maximumNumberOfLines = 1;
    percentageLabel.alignment = NSTextAlignmentCenter;
    
    [_statusItem.button addSubview:percentageLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [percentageLabel.centerYAnchor constraintEqualToAnchor:_statusItem.button.centerYAnchor],
        [percentageLabel.leadingAnchor constraintEqualToAnchor:_statusItem.button.leadingAnchor],
        [percentageLabel.trailingAnchor constraintEqualToAnchor:_statusItem.button.trailingAnchor constant:-2],
        [percentageLabel.heightAnchor constraintEqualToConstant:14],
    ]];
    
    [self updateBatteryInfo];
}
- (void)loadPreferences {
    
    if (!containsKey(@"useFahrenheit")) {
        [preferences setObject:@(YES) forKey:@"useFahrenheit"];
    }
    
    if (!containsKey(@"useBatteryColors")) {
        [preferences setObject:@(YES) forKey:@"useBatteryColors"];
    }
    
    if (!containsKey(@"normalColor")) {
        [preferences setObject:@"#FFFFFFFF" forKey:@"normalColor"];
    }
    
    if (!containsKey(@"chargingColor")) {
        [preferences setObject:@"#28cd41FF" forKey:@"chargingColor"];
    }
    
    if (!containsKey(@"criticalColor")) {
        [preferences setObject:@"#ff3b30FF" forKey:@"criticalColor"];
    }
    
    if (!containsKey(@"lowPowerColor")) {
        [preferences setObject:@"#FEDD11FF" forKey:@"lowPowerColor"];
    }
    
    if (!containsKey(@"textColor")) {
        [preferences setObject:@"#00000099" forKey:@"textColor"];
    }
    
    [preferences synchronize];
}
- (NSImage *)image:(NSImage *)image tintedWithColor:(NSColor *)tint {
    if (tint) {
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositingOperationSourceAtop);
        [image unlockFocus];
    }
    return image;
}
- (void)updateBatteryInfo {
    kern_return_t result;
    mach_port_t port = 0;
    io_registry_entry_t entry = IOServiceGetMatchingService(port, IOServiceMatching("IOPMPowerSource"));
    CFMutableDictionaryRef rawProperties = NULL;
    result = IORegistryEntryCreateCFProperties(entry, &rawProperties, NULL, 0);
    NSDictionary *properties = (__bridge_transfer NSDictionary *)rawProperties;
    
    CGFloat health = ([[properties objectForKey:@"NominalChargeCapacity"] floatValue] / [[properties objectForKey:@"DesignCapacity"] floatValue]) * 100;
    
    BOOL useFahrenheit = [[preferences objectForKey:@"useFahrenheit"] boolValue];
    
    double temperature;
    
    if (useFahrenheit) {
        temperature = (([[properties objectForKey:@"Temperature"] doubleValue] / 100) * (9/5)) + 32;
    } else {
        temperature = ([[properties objectForKey:@"Temperature"] doubleValue] / 100);
    }
    
    [self.cycleLabel setStringValue:[[properties objectForKey:@"CycleCount"] stringValue]];
    [self.healthLabel setStringValue:[NSString stringWithFormat:@"%.f%%", health]];
    [self.temperatureLabel setStringValue:[NSString stringWithFormat:@"%.fº", temperature]];
    [self.amperageLabel setStringValue:[NSString stringWithFormat:@"%.2fA", ([[properties objectForKey:@"Amperage"] doubleValue]) / 1000]];
    [self.voltageLabel setStringValue:[NSString stringWithFormat:@"%.2fV", ([[properties objectForKey:@"Voltage"] doubleValue]) / 1000]];
    [self.powerLabel setStringValue:[NSString stringWithFormat:@"%.fW", ([[properties objectForKey:@"Amperage"] doubleValue] / 1000) * ([[properties objectForKey:@"Voltage"] doubleValue] / 1000)]];
    
    BOOL charging = [[properties objectForKey:@"ExternalConnected"] boolValue];
    
    int capacityRemaining = [[properties objectForKey:@"CurrentCapacity"] intValue];
    NSString *percentageString = [NSString stringWithFormat:@"%d", capacityRemaining];
    
    [_statusItem.button setImage:[self batteryFillImageWithPercentage:(CGFloat)(capacityRemaining) / 100 charging:charging]];
    
    [_statusItem.button setImage:[self batteryFillImageWithPercentage:(CGFloat)(capacityRemaining) / 100 charging:charging]];

    BOOL useBatteryColors = [[preferences objectForKey:@"useBatteryColors"] boolValue];
    
    [percentageLabel setStringValue:percentageString];
    percentageLabel.textColor = (useBatteryColors) ? [self colorFromHexString:[preferences objectForKey:@"textColor"]] : [NSColor colorWithWhite:0 alpha:0.6];
    
    [self.capacityLabel setStringValue:[NSString stringWithFormat:@"%@%%", percentageString]];
    
    if (charging) {
        [self.sourceLabel setStringValue:@"Power Adapter"];
    } else {
        [self.sourceLabel setStringValue:@"Battery"];
    }
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
- (NSImage *)batteryFillImageWithPercentage:(CGFloat)percentage charging:(BOOL)charging {
    
    BOOL useBatteryColors = [[preferences objectForKey:@"useBatteryColors"] boolValue];
    
    NSImage *batteryImage = [NSImage imageNamed:@"battery-light"];
    NSImage *croppedBatteryImage;
    if (charging) {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percentage] tintedWithColor:(useBatteryColors) ? [self colorFromHexString:[preferences objectForKey:@"chargingColor"]] : [NSColor systemGreenColor]];
    } else {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percentage] tintedWithColor:(useBatteryColors) ? [self colorFromHexString:[preferences objectForKey:@"normalColor"]] : [NSColor whiteColor]];
    }
    
    if ((NSInteger)(percentage * 100) <= 10) {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percentage] tintedWithColor:(useBatteryColors) ? [self colorFromHexString:[preferences objectForKey:@"criticalColor"]] : [NSColor systemRedColor]];
    }
    
    if ([[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
        croppedBatteryImage = [self image:[self cropImage:batteryImage toWidthPercentage:percentage] tintedWithColor:(useBatteryColors) ? [self colorFromHexString:[preferences objectForKey:@"lowPowerColor"]] : [self colorFromHexString:@"FEDD11FF"]];
    }
    
    NSImage *finalBatteryImage = [self overlayImage:[NSImage imageNamed:@"battery-light"] withImage:croppedBatteryImage];
    
    return finalBatteryImage;
}
- (NSImage *)cropImage:(NSImage *)image toWidthPercentage:(CGFloat)percentage {
    if (!image || percentage <= 0.0 || percentage > 1.0) {
        return nil;
    }
    NSSize originalSize = [image size];
    
    CGFloat croppedWidth = originalSize.width * percentage;
    CGFloat croppedHeight = originalSize.height;
    
    NSRect sourceRect = NSMakeRect(0, 0, croppedWidth, croppedHeight);
    
    NSImage *croppedImage = [[NSImage alloc] initWithSize:NSMakeSize(originalSize.width, croppedHeight)];
    

    [croppedImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, croppedWidth, croppedHeight)
             fromRect:sourceRect
            operation:NSCompositingOperationCopy
             fraction:1];
    [croppedImage unlockFocus];
    
    return croppedImage;
}
- (NSImage *)overlayImage:(NSImage *)image1 withImage:(NSImage *)image2 {
    if (!image1 || !image2) {
        return nil;
    }
    NSSize finalSize = [image1 size];
    NSImage *resultImage = [[NSImage alloc] initWithSize:finalSize];
    [resultImage lockFocus];
    
    [image1 drawInRect:NSMakeRect(0, 0, finalSize.width, finalSize.height)
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:0.6];
    
    [image2 drawInRect:NSMakeRect(0, 0, finalSize.width, finalSize.height)
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:1.0];
    [resultImage unlockFocus];
    
    return resultImage;
}
- (IBAction)quit:(NSMenuItem *)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}
- (IBAction)showSettings:(id)sender {
    AmpereSettingsController *prefsController = [[AmpereSettingsController alloc] init];
    NSWindow *prefsWindow = [prefsController window];
    NSVisualEffectView *vibrant = [[NSClassFromString(@"NSVisualEffectView") alloc] initWithFrame:[[prefsWindow contentView] bounds]];
    [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [vibrant setIdentifier:@"rfView"];
    [[prefsWindow contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
    [prefsWindow makeKeyAndOrderFront:nil];
    [prefsWindow orderFrontRegardless];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSColor.ignoresAlpha = NO;
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
}
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}
@end
