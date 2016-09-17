//
//  GroupChatViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 5/10/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "GroupChatViewController.h"
#import "ChatTableViewCell.h"
#import "LocalChat.h"
#import "Engine.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+Popup.h"
#import "Stadium.h"
#import "ChatItem.h"
#import "Constants.h"
#import <GrowingTextViewHandler.h>
#import "PhotoManager.h"
#import "MBProgressHUD.h"
#import <Google/Analytics.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import "NSDate+TimeAgo.h"


@interface GroupChatViewController ()<PopupTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) NSMutableArray *localChats;
@property (strong, nonatomic) UIImage *selectedPhoto;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) GrowingTextViewHandler *handler;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) PhotoManager *photoManager;

@property (nonatomic,retain) UIAlertView *alert;

@property (nonatomic) NSInteger replyID;

/***** Video Recording ****/
@property (nonatomic, strong) UIImagePickerController *picker;
@property (strong, nonatomic) AVPlayerViewController *moviePlayer;
@property (nonatomic, retain) NSURL *recordedVideoPath;
@property (nonatomic,retain) NSMutableData *videoData;
@property (nonatomic) BOOL isRecording;
@property (strong, nonatomic) NSMutableArray *visibleIndexs;
@property (strong, nonatomic) NSMutableArray *playedIndexs;
@property (nonatomic, retain) NSTimer *videoTimer;

@end

@implementation GroupChatViewController

@synthesize groupID, groupName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 91.0;
    self.replyID = 0;
    self.isRecording = FALSE;
    self.groupLabel.text = groupName;
    
    self.localChats = [[NSMutableArray alloc] init];
    
    [self getStream];
    [self setupRefresher];
    
    self.handler = [[GrowingTextViewHandler alloc]initWithTextView:self.textView withHeightConstraint:self.heightConstraint];
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:10];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupRefresher
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tblView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(pullDownRefreshed) forControlEvents:UIControlEventValueChanged];
    
    [self.tblView addSubview:self.refreshControl];
}


#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification *)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = -1 * keyboardSize.height;
    
    [self.tblView setContentOffset:CGPointMake(0, self.tblView.contentSize.height)];
    
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}


#pragma mark - IBActions

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBtnSend:(id)sender {
    [self addNewGroupMessage];
}


- (IBAction)clickCam:(id)sender {
   
    /*
    NSString *photo = @"Photo";
    NSString *video = @"Video";
    
    NSMutableArray *photoSources = [NSMutableArray arrayWithCapacity:2];
    [photoSources addObject:photo];
    [photoSources addObject:video];
    
    [UIAlertView showWithTitle:@"Upload Media"
                       message:@"Would you like to Upload Photo or Video?"
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:photoSources
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //self.completition(nil);
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:photo]) {
                              [self showPhotoPopup];
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:video]) {
                              [self clickVideoCam:nil];
                          }
                      }];
    
    */
    
    [self showPhotoPopup];
    
}

- (void) showPhotoPopup {
    
    if (!self.photoManager) {
        self.photoManager = [[PhotoManager alloc] init];
    }
    
    [self.photoManager selectPhotoFromController:self withCompletition:^(UIImage *image) {
        if (image) {
            self.selectedPhoto = image;
            self.cameraButton.selected = YES;
        } else {
            self.selectedPhoto = nil;
            self.cameraButton.selected = NO;
        }
    }];
}

- (IBAction)clickVideoCam:(id)sender {
    
        NSLog(@"I am selecting");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = NO;
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.videoMaximumDuration = 30;
        _picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        _picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePicker Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.videoTimer invalidate];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self.videoTimer invalidate];
    // grab our movie URL
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    NSURL *fileURL = [self grabFileURL:[NSString stringWithFormat:@"%d_%@", rand(), @"video.mov"]];
    _recordedVideoPath = fileURL;
    NSData *movieData = [NSData dataWithContentsOfURL:chosenMovie];
    [movieData writeToURL:fileURL atomically:YES];
    
    // save it to the Camera Roll
    UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
    
    self.cameraButton.selected = YES;
        // and dismiss the picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Video Recording Support

- (NSURL*)grabFileURL:(NSString *)fileName {
    
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    return documentsURL;
}


#pragma UITableView Delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.localChats.count;
}


- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LocalChat *chatItem = self.localChats[indexPath.row];
    
    
    static NSString *identifier1 = @"receiverCellMessage";
    static NSString *identifier2 = @"receiverCellMessageAndPhoto";
    static NSString *identifier3 = @"senderCellMessage";
    static NSString *identifier4 = @"senderCellMessageAndPhoto";
    
    NSString *cellID = nil;
    
    if (chatItem.userId != [[Engine sharedEngine] settingManager].userID) {
        
        cellID =  chatItem.photo.length == 0 ? identifier1 : identifier2;
        cellID = chatItem.videoLink.length > 0 ? identifier2 : cellID;
    }
    else {
        
        cellID =  chatItem.photo.length == 0 ? identifier3 : identifier4;
        cellID = chatItem.videoLink.length > 0 ? identifier4 : cellID;
    }
    
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    [cell setChatItem:chatItem];
    
    NSLog(@"Msg: %@", chatItem.message);
   // cell.lblMessage.text = chatItem.message;
    cell.lblTime.text = [[chatItem dateCreated] timeAgo];
    
    cell.lblMessage.preferredMaxLayoutWidth = 250;
    
    
    if ([cellID isEqualToString:identifier3] || [cellID isEqualToString:identifier4]) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentJustified];
        
        NSDictionary *initialAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                             NSFontAttributeName : [UIFont fontWithName:@"Roboto-Regular" size:14.0],
                                             NSParagraphStyleAttributeName : paragraphStyle
                                             };
        
        cell.lblMessage.backgroundColor = rgbColor(27, 153, 214);
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chatItem.message attributes:initialAttributes];
        
        cell.lblMessage.attributedText = attributedString;
    }
    else {
        
        NSDictionary *initialAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                             NSFontAttributeName : [UIFont fontWithName:@"Roboto-Regular" size:14.0] };
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chatItem.message attributes:initialAttributes];
        NSRange range = [chatItem.message rangeOfString:chatItem.profileName];
        
        NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                          NSFontAttributeName : [UIFont fontWithName:@"Roboto-Bold" size:14.0] };
        [attributedString setAttributes:linkAttributes range:range];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
        
        cell.lblMessage.attributedText = attributedString;
        
        cell.lblMessage.backgroundColor = rgbColor(187, 187, 187);
    }
    
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITextField Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self.handler resizeTextViewWithAnimation:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Loading methods

- (void)pullDownRefreshed
{
    if (![self.refreshControl isRefreshing]) {
        [self.refreshControl beginRefreshing];
    }
    
    [self getStream];
}

- (void)getStream
{
    
    [self getGroupChats];
}

- (void)getGroupChats
{    
    [[[Engine sharedEngine] dataManager] getGroupChatForGroupID:groupID 
                                                    withCallBack:^(BOOL success, id result, NSString *errorInfo)
     {
         if (success) {
             NSLog(@"Result %@",result);
             [self updateTableWithChats:result];
         }
         
         NSLog(@"%@>>%@", errorInfo, result);
     }];
}

- (void)updateTableWithChats:(NSArray *)chats
{
    NSArray *sortedArray = [chats sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        LocalChat *chatItem1 = obj1;
        LocalChat *chatItem2 = obj2;
        
        return [chatItem1.dateCreated compare:chatItem2.dateCreated];
    }];
    
    self.localChats = [NSMutableArray arrayWithArray:sortedArray];
    
    [self.tblView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.localChats.count > 0)
        [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.3];
    
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void) moveToBottom {
    //[self.tblView setContentOffset:CGPointMake(0, self.tblView.contentSize.height)];
    //[self.tblView scrollRectToVisible:CGRectMake(0, self.tblView.contentSize.height, self.tblView.frame.size.width, self.tblView.contentSize.height) animated:YES];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:self.localChats.count-1 inSection: 0];
    [self.tblView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: NO];
}

- (void)addNewGroupMessage
{
    NSString *message = self.textView.text;
    
    CLLocation *location = nil;
    User *currentuser = [[Engine sharedEngine] settingManager].user;
    location = [currentuser getLocation];
   
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    /*
    if (self.cameraButton.isSelected)
        _videoData = [[NSMutableData alloc] initWithContentsOfURL:_recordedVideoPath];
    
    if (_videoData != nil) {
        self.cameraButton.selected = NO;
        [[[Engine sharedEngine] dataManager] createNewLocalchatForLocationWithVideo:location
                                                                        withReplyID:self.replyID
                                                                            message:message
                                                                              video:_videoData
                                                                              photo:self.selectedPhoto
                                                                       withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             NSLog(@"i m here");
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                 LocalChat *chat = (LocalChat *)result;
                 [self postTweetForChat:chat];
                 
                 [self.localChats insertObject:chat atIndex:0];
                 [self.tblView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
             } else {
                 [self showErrorMessage:errorInfo ? errorInfo : @"Failed to create chat"];
             }
             
             _videoData = nil;
             NSLog(@"i m done");
         }];
        
    }
    else {
        */
        [[[Engine sharedEngine] dataManager] createNewGroupMessage:location
                                                               withGroupID:self.groupID
                                                                   message:message
                                                                     photo:self.selectedPhoto
                                                              withCallBack:^(BOOL success, id result, NSString *errorInfo)
         {
             NSLog(@"i m here");
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                 LocalChat *chat = (LocalChat *)result;
                // [self postTweetForChat:chat];
                 [self.localChats addObject:chat];
                 
                 [self.tblView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.localChats.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                 
                 [self.handler setText:nil withAnimation:YES];
               
               //  [self performSelector:@selector(moveToBottom) withObject:nil afterDelay:0.2];
                 
             } else {
                // [self showErrorMessage:errorInfo ? errorInfo : @"Failed to create chat"];
             }
             
             NSLog(@"i m done");
         }];
   // }
    
    [self resetUI];
}

#pragma mark - PopupTableViewCellDelegate

- (void)popupTableViewCell:(PopupTableViewCell *)cell didReplyForChatItem:(id<ChatItem>)chatItem
{
    NSString *name = [chatItem profileName];
    
    self.replyID = [chatItem userId];
    
    [self.handler setText:[NSString stringWithFormat:@"@%@ ",name] withAnimation:YES];
    
    [self.textView becomeFirstResponder];
}

- (void)popupTableViewCell:(PopupTableViewCell *)cell didReportForChatItem:(id<ChatItem>)chatItem
{
    //
}

- (void)popupTableViewCell:(PopupTableViewCell *)cell likeChatItem:(id<ChatItem>)chatItem
{
    LocalChat *localChat = (LocalChat *)chatItem;
    [[[Engine sharedEngine] dataManager] likeLocalChatWithID:localChat.chatId withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"liked");
        }
    }];
}

- (void)popupTableViewCell:(PopupTableViewCell *)cell dislikeChatItem:(id<ChatItem>)chatItem
{
    LocalChat *localChat = (LocalChat *)chatItem;
    [[[Engine sharedEngine] dataManager] dislikeLocalChatWithID:localChat.chatId withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"liked");
        }
    }];
}

#pragma mark - Helpers

- (void)resetUI
{
    self.cameraButton.selected = NO;
    
    self.selectedPhoto = nil;
    [self.handler setText:nil withAnimation:YES];
    
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

- (void)postTweetForChat:(LocalChat *)localChat
{
    
    if (self.twitterButton.selected) {
        
        if (![[[Engine sharedEngine] shareManager] isTwitterConnected]) {
            
            [[[Engine sharedEngine] shareManager] requireTwitterPermisionsWithCallBack:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    [[[Engine sharedEngine] shareManager] isTwitterConnected];
                } else if (errorMessage) {
                    [self showErrorMessage:errorMessage];
                }
            }];
            
        } else {
            
            NSLog(@"will post tweet");
            
            NSString *message = [NSString stringWithFormat:@"%@ (via pfan.co app)", localChat.message];
            NSString *photo = localChat.photo;
            [[[Engine sharedEngine] shareManager] postToTwitterWithMessage:message photoURLString:photo callback:^(BOOL success, NSString *errorMessage) {
                if (!success && errorMessage) {
                    [self showErrorMessage:errorMessage];
                } else {
                    [self showSuccessMessage:@"Tweet posted"];
                }
            }];
        }
    }
}


#pragma mark - video playing mehtods

- (void) playVideo:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:_tblView];
    NSIndexPath *indexPath = [_tblView indexPathForRowAtPoint:buttonPosition];
    
    LocalChat *chatItem = self.localChats[indexPath.row];
    
    NSURL *url = [NSURL URLWithString:chatItem.videoLink];
    _moviePlayer =  [[AVPlayerViewController alloc]
                     init];
    _moviePlayer.showsPlaybackControls = NO;
    _moviePlayer.player = [AVPlayer playerWithURL:url];
    _moviePlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _moviePlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _moviePlayer.view.frame = self.view.frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayerFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_moviePlayer.player currentItem]];
    
    [self.view addSubview:_moviePlayer.view];
    //[self presentViewController:_moviePlayer animated:YES completion:nil];
    
    [[_moviePlayer player] play];
    
    UIButton *closebtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 20, 40, 40)];
    [closebtn setTitle:@"X" forState:UIControlStateNormal];
    [closebtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closebtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:25];
    [closebtn setBackgroundColor:[UIColor clearColor]];
    [closebtn addTarget:self action:@selector(closeBigPlayer)
       forControlEvents:UIControlEventTouchUpInside];
    closebtn.tag = 88;
    
    
    UIButton *pausebtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-15, self.view.frame.size.height-50, 30, 30)];
    [pausebtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
    [pausebtn addTarget:self action:@selector(pauseVideo)
       forControlEvents:UIControlEventTouchUpInside];
    pausebtn.tag = 99;
    
    [_moviePlayer.view addSubview: closebtn];
    [_moviePlayer.view bringSubviewToFront: closebtn];
    [_moviePlayer.view addSubview: pausebtn];
    [_moviePlayer.view bringSubviewToFront: pausebtn];
    
}

- (void) pauseVideo {
    
    [[_moviePlayer player] pause];
    [[_moviePlayer.view viewWithTag:99] removeFromSuperview];
    
    UIButton *playbtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-15, self.view.frame.size.height-50, 30, 30)];
    [playbtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    [playbtn addTarget:self action:@selector(playVideo)
      forControlEvents:UIControlEventTouchUpInside];
    playbtn.tag = 77;
    
    [_moviePlayer.view addSubview: playbtn];
    [_moviePlayer.view bringSubviewToFront: playbtn];
}

- (void) playVideo {
    
    [[_moviePlayer player] play];
    [[_moviePlayer.view viewWithTag:77] removeFromSuperview];
    
    UIButton *pausebtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-15, self.view.frame.size.height-50, 30, 30)];
    [pausebtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
    [pausebtn addTarget:self action:@selector(pauseVideo)
       forControlEvents:UIControlEventTouchUpInside];
    pausebtn.tag = 99;
    
    [_moviePlayer.view addSubview: pausebtn];
    [_moviePlayer.view bringSubviewToFront: pausebtn];
}

- (void) videoPlayerFinishPlaying:(NSNotification*)notification {
    
    NSLog(@"its called");
    AVPlayerItem *player = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:player];
    [self closeBigPlayer];
}

- (void) closeBigPlayer {
    
    [[_moviePlayer player] setRate:0.0];
    [_moviePlayer.view removeFromSuperview];
    _moviePlayer = nil;
}

@end
