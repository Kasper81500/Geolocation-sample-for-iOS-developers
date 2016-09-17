//
//  SocialViewController.h
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialViewController : UIViewController

@property (nonatomic) BOOL isHideSkipButton;

+ (BOOL)wasVisisbleBeforeTerminated;
+ (BOOL)wasSkipButtonHidden;
+ (BOOL)wasPrevScreenSettings;

@end
