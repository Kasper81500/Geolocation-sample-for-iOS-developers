//
//  ChatViewController.h
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stadium;

@interface ChatViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    int maxDuration;
}

@property (nonatomic, strong) Stadium *stadium;

@end
