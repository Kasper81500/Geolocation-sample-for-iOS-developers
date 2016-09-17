//
//  CircleColorButton.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/13/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "CircleColorButton.h"
#import "Constants.h"

@implementation CircleColorButton

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!self.fillColor) {
        self.fillColor = rgbColor(247.0, 247.0, 247.0);
    }
    
    if (!self.strokeColor) {
        self.strokeColor = rgbColor(214.0, 214.0, 214.0);
    }
    
    [self.strokeColor setStroke];
    [self.fillColor setFill];
    
    CGFloat offset = 2.0;
    
    CGContextSetLineWidth(context, offset*2);
    
    CGContextAddEllipseInRect(context, CGRectInset(rect, offset, offset));
    
    if (self.state == UIControlStateSelected) {
        CGContextDrawPath(context, kCGPathEOFillStroke);
    } else {
        CGContextFillPath(context);
    }    
}

@end
