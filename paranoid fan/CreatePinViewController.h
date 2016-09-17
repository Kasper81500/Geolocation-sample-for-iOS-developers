//
//  CreatePinViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreatePinViewController;
@class Pin;

@protocol CreatePinViewControllerDelegate <NSObject>

- (void)createPinViewController:(CreatePinViewController *)pinVC didAddPin:(Pin *)pin;
- (void)createPinViewControllerFailureToAddPin:(CreatePinViewController *)pinVC;
- (void)createPinViewController:(CreatePinViewController *)pinVC wantShareViaFB:(BOOL)isFB viaTwitter:(BOOL)isTwitter withPin:(Pin *)pin;
- (void)createPinViewController:(CreatePinViewController *)pinVC wantInviteFriends:(NSArray *)usersToInvite withPin:(Pin *)pin;

@end

@interface CreatePinViewController : UIViewController

@property (nonatomic, weak) id<CreatePinViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *menuType;
@property (nonatomic, strong) NSString *pinType;
@property (nonatomic, strong) UIImage *pinImage;

@end
