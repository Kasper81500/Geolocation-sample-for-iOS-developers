//
//  BorderView.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/9/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "BorderView.h"
#import "Constants.h"

@implementation BorderView

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
    
    CGContextClearRect(context, rect);
    
    if (!self.fillColor) {
        self.fillColor = rgbColor(247.0, 247.0, 247.0);
    }
    
    if (!self.strokeColor) {
        self.strokeColor = rgbColor(214.0, 214.0, 214.0);
    }
    
    [self.strokeColor setStroke];
    [self.fillColor setFill];
    
   
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
    [path setLineWidth:self.borderWidth];
    
    [path closePath];    
    [path fill];
    [path stroke];
    
    
}


@end
