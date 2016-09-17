//
//  BorderView.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/9/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface BorderView : UIView

@property (nonatomic) IBInspectable UIColor *fillColor;
@property (nonatomic) IBInspectable UIColor *strokeColor;
@property (nonatomic) IBInspectable NSInteger cornerRadius;
@property (nonatomic) IBInspectable NSInteger borderWidth;


@end
