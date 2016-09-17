//
//  ReviewListViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 3/28/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pin.h"

@class ReviewListViewController;

@protocol ReviewListViewControllerDelegate <NSObject>

- (void)showPinDetailFromReview:(ReviewListViewController *)reviewListVC didTapOnPin:(Pin *)pin;

@end

@interface ReviewListViewController : UIViewController

@property (strong, nonatomic) NSString *profileID;

@property (nonatomic, weak) id<ReviewListViewControllerDelegate> delegate;

@end
