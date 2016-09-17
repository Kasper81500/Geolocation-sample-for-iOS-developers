//
//  MessagesViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 4/24/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "MessagesViewController.h"
#import "Engine.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+Popup.h"
#import "Message.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "MessageTableViewCell.h"
#import <GrowingTextViewHandler/GrowingTextViewHandler.h>
#import "NSDate+TimeAgo.h"
#import "PhotoManager.h"

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleName;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) GrowingTextViewHandler *handler;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSArray *stickerIcons;
@property (weak, nonatomic) NSString *selectedSticker;
@property (weak, nonatomic) NSTimer *refresher;
@property (nonatomic) NSInteger lastID;

@property (weak, nonatomic) IBOutlet UIScrollView *stickers;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *stickerButton;
@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) PhotoManager *photoManager;

@end

@implementation MessagesViewController

int viewHeight;

@synthesize receiverID, receiverName, isGroup, groupID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblView.delaysContentTouches = NO;
    self.tblView.estimatedRowHeight = 250.0;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    
    self.handler = [[GrowingTextViewHandler alloc]initWithTextView:self.textView withHeightConstraint:self.heightConstraint];
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:10];
    
    self.textView.text = @"Type your message here";
    self.textView.textColor = [UIColor lightGrayColor];
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    
    NSLog(@"Receivers %@", receiverName);
    self.titleName.text = receiverName;
    
    self.tblView.hidden = YES;
    
    self.messages = [[NSMutableArray alloc] init];
    
    [self getAllMessages];
    
    self.refresher = [NSTimer scheduledTimerWithTimeInterval:15.0f
                                                      target:self selector:@selector(refreshMessages) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllMessages) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

/*
- (void)viewWillAppear:(BOOL)animated {
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [self.textView becomeFirstResponder];
}

/*
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.refresher invalidate];
}

*/
#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification *)notification {
    // Get the size of the keyboard.
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = -1 * keyboardSize.height;
    
    if (viewHeight != keyboardSize.height) {
        viewHeight = keyboardSize.height;
        [self setupStickers];
    }
    
    //[self.tblView setContentOffset:CGPointMake(0, self.tblView.contentSize.height)];
    
    if (self.stickerButton.selected) {
        self.stickerButton.selected = NO;
        self.navTopConstraint.constant = 1;
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}



#pragma mark - IBActions

- (IBAction)clickBackBtn:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.refresher invalidate];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBtnSend:(id)sender {
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.btnSend.enabled = FALSE;
    [self sendMessage];
}

- (IBAction)clickCam:(id)sender {
    
    [self showPhotoPopup];
}

- (IBAction)clickGallery:(id)sender {
    
    [self showAlbumPopup];
}

- (IBAction)clickStickers:(id)sender {
    
    if ([self.textView isFirstResponder])
        [self.textView resignFirstResponder];
    
    [self.view layoutIfNeeded];
    
    if (!self.stickerButton.isSelected) {
        
        self.bottomConstraint.constant = -1 * viewHeight;
        self.navTopConstraint.constant = -1 * viewHeight;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            self.stickerButton.selected = YES;
        }
         ];
    }
    else {
        
        self.bottomConstraint.constant = 0;
        self.navTopConstraint.constant = 1;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            self.stickerButton.selected = NO;
        }
         ];
    }
    
    [self moveToBottom];
}

- (IBAction)clickText:(id)sender {
    
    [self.textView becomeFirstResponder];
}

- (void) showPhotoPopup {
    
    if (!self.photoManager) {
        self.photoManager = [[PhotoManager alloc] init];
    }
    
    [self.photoManager selectCameraFromController:self withCompletition:^(UIImage *image) {
        if (image) {
            self.selectedPhoto = image;
            self.cameraButton.selected = YES;
            [self sendMessage];
        } else {
            self.selectedPhoto = nil;
            self.cameraButton.selected = NO;
        }
        
        [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.2];
        
    }];
}

- (void) showAlbumPopup {
    
    if (!self.photoManager) {
        self.photoManager = [[PhotoManager alloc] init];
    }
    
    [self.photoManager selectAlbumFromController:self withCompletition:^(UIImage *image) {
        if (image) {
            self.selectedPhoto = image;
            self.galleryButton.selected = YES;
            [self sendMessage];
        } else {
            self.selectedPhoto = nil;
            self.galleryButton.selected = NO;
        }
        
        [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.2];
        
    }];
}

#pragma UITableView Delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70.0;
//}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *message = self.messages[indexPath.row];
    
    
    static NSString *identifier1 = @"senderCellMessage";
    static NSString *identifier2 = @"receiverCellMessage";
    static NSString *identifier3 = @"senderCellMessagePhoto";
    static NSString *identifier4 = @"receiverCellMessagePhoto";
    static NSString *identifier5 = @"senderCellSticker";
    static NSString *identifier6 = @"receiverCellSticker";
    
    NSString *cellID;
    
    if (receiverID > 0)
        cellID =  message.receiverId == receiverID ? identifier1 : identifier2;
    else if (groupID > 0)
        cellID =  message.senderId == [[Engine sharedEngine] settingManager].userID ? identifier1 : identifier2;
    
    if ([cellID isEqualToString:identifier1] && message.photo.length > 0)
        cellID = identifier3;
    else if ([cellID isEqualToString:identifier2] && message.photo.length > 0)
        cellID = identifier4;
    else if ([cellID isEqualToString:identifier1] && message.sticker.length > 0)
        cellID = identifier5;
    else if ([cellID isEqualToString:identifier2] && message.sticker.length > 0)
        cellID = identifier6;
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell.contentView layoutIfNeeded];
    
    if (message.sticker.length > 0) {
        
        [cell.sticker setImage:[UIImage imageNamed:message.sticker]];
    }
    else {
        
        if ([cellID isEqualToString:identifier1] || [cellID isEqualToString:identifier3]) {
            
            cell.msgTxt.backgroundColor = rgbColor(27, 153, 214);
        }
        else {
            
            cell.msgTxt.backgroundColor = rgbColor(187, 187, 187);
        }
        
        cell.msgTxt.preferredMaxLayoutWidth = 250;
        cell.msgTxt.numberOfLines = 0;
        
        if (message.photo.length > 0) {
            
            CGFloat currentWidth = 410;
            if ([UIScreen mainScreen].bounds.size.width == 375)
                currentWidth = 371;
            else if ([UIScreen mainScreen].bounds.size.width == 320)
                currentWidth = 316;
            
            float newImageHeight = 0;
            float newImageWidth = 0;
            float imageWidth = 0;
            float imageHeight = 0;
            float ratio = 0;
            
            imageWidth = message.imageWidth;
            imageHeight = message.imageHeight;
        
            ratio = currentWidth / imageWidth;
            newImageHeight = ratio * imageHeight;
            newImageWidth = currentWidth;
        
            cell.photoHeightConstraint.constant = newImageHeight;
        }
    }
    
    if (message.messageId > self.lastID)
        self.lastID = message.messageId;
    
    [cell setChatItem:message];
    
//    cell.delegate = self;
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - UITextViewDelegate


- (void)textViewDidChange:(UITextView *)textView {
    
    NSLog(@"changing.....");
    [self.handler resizeTextViewWithAnimation:YES];
    
    if(self.textView.text.length == 0){
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.text = @"Type your message here";
        [self.textView resignFirstResponder];
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.textView.text = @"";
    self.textView.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView {
    
    if(self.textView.text.length == 0){
        self.textView.textColor = [UIColor lightGrayColor];
        self.textView.text = @"Type your message here";
        [self.textView resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Loading Methods

- (void) getAllMessages
{
    self.lastID = 0;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (isGroup) {
        
        [[[Engine sharedEngine] dataManager] getUserGroupMessages:[[[Engine sharedEngine] settingManager] userID] toGroup:self.groupID fromLastID:self.lastID
                                                  withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                 NSLog(@"Result %@",result);
                 
                 NSArray *chats = (NSArray *)result;
                 self.messages = [NSMutableArray arrayWithArray:chats];
                 
                 [self.tblView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                 
                 if (self.messages.count > 0)
                     [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.3];
                 
                 [self performSelector:@selector(showTableView) withObject:nil afterDelay:0.7];
             }
         }];
    }
    else {
        
        [[[Engine sharedEngine] dataManager] getDirectMessages:[[[Engine sharedEngine] settingManager] userID] toReceiver:receiverID fromLastID:self.lastID
                          withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {

             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                 NSLog(@"Result %@",result);
                 
                 NSArray *chats = (NSArray *)result;
                 self.messages = [NSMutableArray arrayWithArray:chats];
                 
                 [self.tblView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                 
                 if (self.messages.count > 0)
                     [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.3];
                 
                 [self performSelector:@selector(showTableView) withObject:nil afterDelay:0.7];
                 //[self.tblView scrollRectToVisible:CGRectMake(0, self.tblView.contentSize.height, self.tblView.frame.size.width, self.tblView.contentSize.height) animated:YES];
             }
         }];
    }
}

- (void) showTableView {
    
    self.tblView.hidden = NO;
}

- (void) moveToBottom {
    //[self.tblView setContentOffset:CGPointMake(0, self.tblView.contentSize.height)];
    //[self.tblView scrollRectToVisible:CGRectMake(0, self.tblView.contentSize.height, self.tblView.frame.size.width, self.tblView.contentSize.height) animated:YES];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection: 0];
    [self.tblView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: NO];
}

- (void) refreshMessages
{
    
    if (isGroup) {
        
        [[[Engine sharedEngine] dataManager] getUserGroupMessages:[[[Engine sharedEngine] settingManager] userID] toGroup:self.groupID fromLastID:self.lastID
                                                  withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             
             if (success) {
                 NSLog(@"Result %@",result);
                 
                 NSArray *chats = (NSArray *)result;
                 
                 if (chats.count > 0) {
                     
                     [self updateTableWithChats:chats];
                     
                /*     [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                     
                     [self.tblView setContentOffset:CGPointMake(0, self.tblView.contentSize.height)];
                 */
                 }
                 
             }
         }];
    }
    else {
        
        [[[Engine sharedEngine] dataManager] getDirectMessages:[[[Engine sharedEngine] settingManager] userID] toReceiver:receiverID fromLastID:self.lastID
                                                  withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             
             if (success) {
                 NSLog(@"Result %@",result);
                 
                 NSArray *chats = (NSArray *)result;
                 
                 if (chats.count > 0) {
                     
                     [self updateTableWithChats:chats];
                     
                   /*  [self.tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                  
                     [self.tblView setContentOffset:CGPointMake(0, self.tblView.contentSize.height)];
                    */
                 }
                 
             }
         }];
    }
}

- (void)updateTableWithChats:(NSArray *)chats
{
    
    for (int i=0; i<chats.count; i++) {
        
        [self.messages addObject:chats[i]];
        
        [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

    }
}

- (void) sendMessage {
    
    CLLocation *location = [[[[Engine sharedEngine] settingManager] user] getLocation];
    
    if ([self.textView.text isEqualToString:@"Type your message here"])
        self.textView.text = @"";
    
    if (isGroup) {
        NSLog(@"Sending group messsage");
        [[[Engine sharedEngine] dataManager] createNewMessageForGroup:location message:self.textView.text senderID:[[[Engine sharedEngine] settingManager] userID] groupID:self.groupID photo:self.selectedPhoto sticker:self.selectedSticker withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             if (success) {
                 NSLog(@"Sent group messsage");
                 
                 Message *message = (Message *)result;
                 
                 [self.messages addObject:message];
                 [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                 
                 [self.handler setText:nil withAnimation:YES];
                 
                 self.selectedSticker = @"";
                 
                 self.btnSend.enabled = TRUE;
                 
                 self.galleryButton.selected = NO;
                 
                 self.cameraButton.selected = NO;
                 
                 [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.3];
                 
                 
             } else {
                 //[self showErrorMessage:errorInfo ? errorInfo : @"Failed to create chat"];
             }
         }];
    }
    else {
    
        [[[Engine sharedEngine] dataManager] createNewMessage:location message:self.textView.text senderID:[[[Engine sharedEngine] settingManager] userID] receiverID:receiverID photo:self.selectedPhoto sticker:self.selectedSticker withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             if (success) {
              
                 
                 Message *message = (Message *)result;
                 
                 [self.messages addObject:message];
                 [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
              
                 
                 [self.handler setText:nil withAnimation:YES];
                 
                 self.selectedSticker = @"";
                 
                 self.btnSend.enabled = TRUE;
                 
                 self.galleryButton.selected = NO;
                 
                 self.cameraButton.selected = NO;
                 
                 [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.3];
                 
                 
             } else {
                 //[self showErrorMessage:errorInfo ? errorInfo : @"Failed to create chat"];
             }
         }];
    }
}

- (void) setupStickers {
    
    self.selectedSticker = @"";
    float factor = self.view.frame.size.width/320;
    
    self.stickerHeightConstraint.constant = viewHeight;
    self.stickers.contentSize = CGSizeMake(self.view.frame.size.width*2, viewHeight);
    self.stickers.pagingEnabled = YES;
    
    float startX = 4;
    float startY = 4;
    int padding = 12*factor;
    int width = 42.0*factor;
    int height = 42.0*factor;
    
    self.stickerIcons = @[@"boy_smile",
                          @"boy_sad",
                          @"boy_angry",
                          @"boy_wasntme",
                          @"boy_crying",
                          @"boy_sweat",
                          @"vampire_sweat",
                          @"monster_sad",
                          @"monster_angry",
                          @"monster_wasntme",
                          @"zombie_quite",
                          @"zombie_sad",
                          @"boy_scared",
                          @"boy_wink",
                          @"girl_smile",
                          @"girl_sad",
                          @"girl_angry",
                          @"girl_wasntme",
                          @"zombie_smile",
                          @"burger",
                          @"hotdog",
                          @"icecream",
                          @"lolipop",
                          @"pizza",
                          @"girl_crying",
                          @"girl_sweat",
                          @"girl_scared",
                          @"girl_wink",
                          @"vampire_smile",
                          @"vampire_angry",
                          @"Beer",
                          @"rocket",
                          @"shark",
                          @"viking",
                          @"ghost",
                          @"mummy"];
    
    for (int i=0; i<self.stickerIcons.count; i++) {

        UIImageView *btn = [[UIImageView alloc] init];
        btn.tag = 900+i;
        btn.frame = CGRectMake(startX, startY, width, height);
        btn.image = [UIImage imageNamed:self.stickerIcons[i]];
        btn.contentMode = UIViewContentModeScaleAspectFit;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        tapGesture.numberOfTapsRequired = 1;
        [tapGesture addTarget:self action:@selector(postSticker:)];
        
        btn.userInteractionEnabled = YES;
        [btn addGestureRecognizer:tapGesture];
        
        startX += width+padding;
        
        if (startX > (self.view.frame.size.width*2)) {
            startX = 4;
            startY += height+padding;
        }
        
        [self.stickers addSubview:btn];
    }
}

- (void) postSticker:(UITapGestureRecognizer *) sender {
    
    UIImageView *sticker = (UIImageView *)sender.view;
    self.selectedSticker = self.stickerIcons[sticker.tag-900];
    NSLog(@"Sticker: %@", self.stickerIcons[sticker.tag-900]);
    [self sendMessage];
    //[self clickStickers:nil];
    
}

@end
