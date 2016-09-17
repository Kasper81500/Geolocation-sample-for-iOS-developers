//
//  PinDetailsViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  Pin;
@class PinDetailsViewController;

@protocol PinDetailsViewControllerDelegate <NSObject>

- (void)removePin:(PinDetailsViewController *)pinDetailsVC withPin:(Pin *)pin;

@end


@interface PinDetailsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    int maxDuration;
}

@property (nonatomic, weak) Pin *pin;
@property (nonatomic, weak) id<PinDetailsViewControllerDelegate> delegate;

@end
