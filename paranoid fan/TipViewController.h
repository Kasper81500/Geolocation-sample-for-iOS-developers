//
//  TipViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 3/5/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinChatItem.h"

@interface TipViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, weak) PinChatItem *pinChatItem;

@end
