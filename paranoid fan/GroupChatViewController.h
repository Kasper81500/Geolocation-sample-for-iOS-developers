//
//  GroupChatViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 5/10/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) NSInteger groupID;
@property (nonatomic, strong) NSString *groupName;

@end
