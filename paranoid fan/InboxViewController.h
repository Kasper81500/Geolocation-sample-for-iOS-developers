//
//  InboxViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 5/4/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InboxViewController;

@protocol InboxViewControllerDelegate <NSObject>

@optional

- (void)inboxViewController:(InboxViewController *)inboxViewController withLatitude:(double)latitude withLongitude:(double)longitude;

@end

@interface InboxViewController : UIViewController

@property (nonatomic, weak) id<InboxViewControllerDelegate> inboxDelegate;

@end
