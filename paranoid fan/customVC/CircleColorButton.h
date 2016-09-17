//
//  CircleColorButton.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/13/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface CircleColorButton : UIButton

@property (nonatomic) IBInspectable UIColor *fillColor;
@property (nonatomic) IBInspectable UIColor *strokeColor;

@end
