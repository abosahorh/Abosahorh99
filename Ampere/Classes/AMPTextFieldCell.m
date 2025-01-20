//
//  VerticalTextFieldCell.m
//  Ampere
//
//  Created by DF on 1/20/25.
//

#import "AMPTextFieldCell.h"

@implementation AMPTextFieldCell
- (NSRect)titleRectForBounds:(NSRect)frame {
    CGFloat stringHeight = self.attributedStringValue.size.height;
    CGFloat stringWidth = self.attributedStringValue.size.width;
    NSRect titleRect = [super titleRectForBounds:frame];
    CGFloat originY = frame.origin.y;
    CGFloat originX = frame.origin.x;
    titleRect.origin.y = frame.origin.y + (frame.size.height - stringHeight) / 2.0;
    titleRect.size.height = titleRect.size.height - (titleRect.origin.y - originY);
    titleRect.origin.x = frame.origin.x + (frame.size.width - stringWidth) / 2.0;
    titleRect.size.width = titleRect.size.width - (titleRect.origin.x - originX);
    return titleRect;
}
- (void)drawInteriorWithFrame:(NSRect)cFrame inView:(NSView*)cView {
    [super drawInteriorWithFrame:[self titleRectForBounds:cFrame] inView:cView];
}
@end
