//
//  AddCardViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 3/9/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCardViewController : UIViewController <UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, retain) NSString *onBoarding;

@end
