//
//  PopupTableViewCell.h
//  paranoid fan
//
//  Created by Ferenc Knebl on 01/09/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ChatItem.h"

@class PopupTableViewCell;

@protocol PopupTableViewCellDelegate <NSObject>

@optional

- (void)popupTableViewCell:(PopupTableViewCell *)cell didReplyForChatItem:(id<ChatItem>)chatItem;
- (void)popupTableViewCell:(PopupTableViewCell *)cell didReportForChatItem:(id<ChatItem>)chatItem;
- (void)popupTableViewCell:(PopupTableViewCell *)cell likeChatItem:(id<ChatItem>)chatItem;
- (void)popupTableViewCell:(PopupTableViewCell *)cell dislikeChatItem:(id<ChatItem>)chatItem;
- (void)popupTableViewCell:(PopupTableViewCell *)cell tipChatItem:(id<ChatItem>)chatItem;

@end

@interface PopupTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgViewProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPanorama;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnReply;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet UIButton *btnHeart;
@property (weak, nonatomic) IBOutlet UIButton *btnCoin;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) AVPlayerViewController *videoPlayer;

@property (weak, nonatomic) id<PopupTableViewCellDelegate> delegate;
@property (weak, nonatomic) id<ChatItem> chatItem;

@end
