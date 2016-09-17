//
//  MessagesViewController.h
//  paranoid fan
//
//  Created by Adeel Asim on 4/24/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController : UIViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) NSInteger receiverID;
@property (nonatomic) BOOL isGroup;
@property (nonatomic, strong) NSString *receiverName;
@property (nonatomic) NSInteger groupID;

@end
