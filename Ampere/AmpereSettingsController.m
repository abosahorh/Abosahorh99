//
//  AmpereSettingsController.m
//  Ampere
//
//  Created by DF on 1/14/25.
//

#import "AmpereSettingsController.h"

@interface AmpereSettingsController ()
@end

@implementation AmpereSettingsController
- (id)init {
    self = [super initWithWindowNibName:@"AmpereSettingsController"];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}
- (void)objectDidBecomeKey:(NSNotification *)notification {
    [self removeBackground:[notification object]];
}
- (void)windowDidLoad {
    [super windowDidLoad];
    [self removeBackground:self.window];
}
- (void)removeBackground:(NSWindow *)window {
    [window setBackgroundColor:[NSColor clearColor]];
    NSVisualEffectView *effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, window.contentView.bounds.size.width, window.contentView.bounds.size.height + 30)];
    [effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [effectView setState:NSVisualEffectStateActive];
    [[window contentView] addSubview:effectView positioned:NSWindowBelow relativeTo:nil];

    [window.contentView setWantsLayer:YES];
    window.contentView.layer.backgroundColor = [NSColor clearColor].CGColor;
}
@end
