//
//  GridMenuViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GridMenuViewController;

@protocol GridMenuViewControllerDelegate <NSObject>

- (void)gridMenu:(GridMenuViewController *)gridMenuVC didTapOnButton:(UIButton *)button;
- (void)gridMenu:(GridMenuViewController *)gridMenuVC didTapOnUniqueButton:(UIButton *)button withID:(NSString *)uniqueID;
- (void)gridMenuDidTapBackground:(GridMenuViewController *)gridMenuVC;

@end

#define kFriendList	 @"friendList"
#define kMeetMe	 @"kMeetMe"
#define kLeaderboard	 @"kLeaderboard"
#define kMyProfile	 @"profileView"
#define kMyGroups	 @"mygroupsVC"

@interface GridMenuViewController : UIViewController

@property (nonatomic, weak) id<GridMenuViewControllerDelegate> delegate;

- (IBAction)menuButtonTaped:(UIButton *)sender;
- (IBAction)uniqueButtonTaped:(UIButton *)sender;

@end
