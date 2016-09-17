//
//  TransferFundsViewController.h
//  Paranoid Fan
//
//  Created by Adeel Asim on 6/29/16.
//  Copyright © 2016 Paranoid Fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransferFundsViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic) NSInteger receiverID;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic) BOOL isGroup;

@end
