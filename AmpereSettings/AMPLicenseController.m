//
//  AMPLicenseController.m
//  AmpereSettings
//
//  Created by DF on 1/19/25.
//

#import "AMPLicenseController.h"

@interface AMPLicenseController ()
@end

@implementation AMPLicenseController
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)openLink:(NSButton *)sender {
    NSString *link;
    switch (sender.tag) {
        case 0:
            link = @"https://github.com/MTACS/AmpereMac";
            break;
        case 1:
            link = @"https://github.com/MTACS/AmpereMac/blob/main/LICENSE";
            break;
        case 2:
            link = @"https://github.com/iluuu1994/ITSwitch";
            break;
        case 3:
            link = @"https://github.com/iluuu1994/ITSwitch/blob/master/LICENSE";
            break;
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:link]];
}
@end
