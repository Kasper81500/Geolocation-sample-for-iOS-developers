//
//  EventListViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 3/27/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHandler.h"
#import "Pin.h"

@class EventListViewController;

@protocol EventListViewControllerDelegate <NSObject>

- (void)showPinDetailFromEvent:(EventListViewController *)eventListVC didTapOnPin:(Pin *)pin;

@end

@interface EventListViewController : UIViewController

@property (nonatomic, weak) id<EventListViewControllerDelegate> delegate;

@end
