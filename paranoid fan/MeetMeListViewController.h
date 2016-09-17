//
//  MeetMeListViewController.h
//  Paranoid Fan
//
//  Created by Adeel Asim on 5/26/16.
//  Copyright © 2016 Paranoid Fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeetMeListViewController;

@protocol MeetMeListViewControllerDelegate <NSObject>

- (void)confirmInvites:(MeetMeListViewController *)meetMeListVC withContacts:(NSMutableArray *)contacts withReceivers:(NSMutableArray *)receivers withGroups:(NSMutableArray *)groups;

@end


@interface MeetMeListViewController : UIViewController

@property (nonatomic, strong) NSString *meetMeText;
@property (nonatomic) BOOL isInvite;
@property (nonatomic) BOOL isShare;
@property (nonatomic) BOOL isGroupInvite;
@property (nonatomic) BOOL showGroups;
@property (nonatomic) NSInteger groupID;
@property (nonatomic) NSInteger pinID;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSString *groupname;
@property (nonatomic, strong) NSString *team;
@property (nonatomic, strong) UIImage *photo;

@property (nonatomic, weak) id<MeetMeListViewControllerDelegate> delegate;

@end
