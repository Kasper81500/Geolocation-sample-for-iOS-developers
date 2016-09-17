//
//  ChatViewController.m
//  paranoid fan
//
//  Created by XingGao on 2015-08-28.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "ChatViewController.h"
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


@interface ChatViewController ()<PopupTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *vidCameraButton;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stadiumViewHeightConstraint;
//@property (weak, nonatomic) IBOutlet UIButton *stadiumNameButton;

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

@implementation ChatViewController

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Chat View Controller"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 91.0;
    self.replyID = 0;
    self.isRecording = FALSE;
    _visibleIndexs = [[NSMutableArray alloc] init];
    _playedIndexs = [[NSMutableArray alloc] init];
    
    [self getStream];
    [self setupRefresher];
//    [self setNeedsStatusBarAppearanceUpdate];
    
    self.handler = [[GrowingTextViewHandler alloc]initWithTextView:self.textView withHeightConstraint:self.heightConstraint];
    [self.handler updateMinimumNumberOfLines:1 andMaximumNumberOfLine:10];
    
    [self checkIfFarAway];
    
   // [self setStadiumName];
    
   /* if (self.stadium) {
        NSLog(@"%@", self.stadium.name);
    }*/
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

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
    self.bottomConstraint.constant = keyboardSize.height;
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}



#pragma mark - IBActions

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickBtnSend:(id)sender {
    [self addNewLocalChat];
}

- (IBAction)clickTwitter:(UIButton *)sender {
    
    if (sender.selected)
        self.twitterButton.selected = NO;
    else
        self.twitterButton.selected = YES;
}

- (IBAction)clickCam:(id)sender {
    
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
    
    if (self.vidCameraButton.isSelected) {
        NSLog(@"I am deselecting");
        self.vidCameraButton.selected = NO;
        return;
    }
    NSLog(@"I am selecting");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        maxDuration = 30;
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = NO;
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.videoMaximumDuration = maxDuration;
        _picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        _picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
      /*
        CGRect f = _picker.view.bounds;
        f.size.height -= _picker.navigationBar.bounds.size.height;
        UIGraphicsBeginImageContext(f.size);
        [[UIColor colorWithWhite:0 alpha:1.0] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, 124.0), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, 444, f.size.width, 200), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
        overlayIV.image = overlayImage;
        overlayIV.alpha = 1.0f;
        
        [_picker setCameraOverlayView:overlayIV];*/
        
        [self presentViewController:_picker animated:YES completion:nil];
    }
}

-(void) changeValue {
    
    maxDuration -= 1;
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = [NSString stringWithFormat:@"Time Remaining: %d seconds", maxDuration];
    timeLabel.font = [UIFont fontWithName:@"Arial" size:13.0];
    timeLabel.textColor = [UIColor whiteColor];
    CGAffineTransform transformRotate = CGAffineTransformMakeRotation((M_PI  / 2));
    timeLabel.transform = transformRotate;
    
    UIView *myOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [myOverlay addGestureRecognizer:gesture];
    [myOverlay addSubview:timeLabel];
    [_picker setCameraOverlayView:myOverlay];
}

-(void)tapped:(id)sender {
    
    if (_isRecording) {
        [_picker stopVideoCapture];
        NSLog(@"Video capturing stopped...");
        // add your business logic here ie stop updating progress bar etc...
        [_picker.cameraOverlayView setHidden:YES];
        _isRecording = NO;
        [self.videoTimer invalidate];
        return;
    }
    
    if ([_picker startVideoCapture]) {
        NSLog(@"Video capturing started...");
        // add your business logic here ie start updating progress bar etc...
        _isRecording = YES;
        self.videoTimer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeValue) userInfo:nil repeats:YES];
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
    
    //UIButton *btn = (UIButton *)[self.view viewWithTag:67];
    //[btn setSelected:YES];
   /*
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_recordedVideoPath options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *videoPath = [NSString stringWithFormat:@"%@/%d_pf_video.mp4", [paths objectAtIndex:0], rand()];
        _recordedVideoPath = [NSURL fileURLWithPath:videoPath];
        exportSession.outputURL = _recordedVideoPath;
        NSLog(@"videopath of your mp4 file = %@",videoPath);  // PATH OF YOUR .mp4 FILE
        exportSession.outputFileType = AVFileTypeMPEG4;

        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                    
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"Export canceled");
                    
                    break;
                    
                default:
                    
                    break;
                    
            }
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, nil, nil);
            
        }];
        
    }
    */
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


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (self.stadium) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        [headerView setBackgroundColor:rgbaColor(243, 243, 243, 1.0)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        
        CGRect idealFrame = [self.stadium.name boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 22)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Arial" size:13.0] }
                                               context:nil];
        float starticon = tableView.frame.size.width/2 - idealFrame.size.width/2 - 25;
        
        UIImage *icon = [UIImage imageNamed:@"menu_venue"];
        UIImageView *icon_v = [[UIImageView alloc] init];
        [icon_v setFrame:CGRectMake(starticon, 2, 19, 17)];
        [icon_v setImage:icon];
        [headerView addSubview:icon_v];
        
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = self.stadium.name;
        [headerLabel setTextColor:rgbaColor(2, 163, 254, 1.0)];

        [headerLabel setFont:[UIFont fontWithName:@"Arial" size:13.0]];
        
        
        [headerView addSubview:headerLabel];
        
        return headerView;
        
    }
    else {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        [headerView setBackgroundColor:rgbaColor(243, 243, 243, 1.0)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,22)];
        
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = @"Local";
        [headerLabel setTextColor:rgbaColor(2, 163, 254, 1.0)];
        
        [headerLabel setFont:[UIFont fontWithName:@"Arial" size:13.0]];
        
        
        [headerView addSubview:headerLabel];
        
        return headerView;
        
    }
    
}
/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ChatTableViewCell *video_cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (video_cell.videoPlayer != nil && ![_playedIndexs containsObject:indexPath]) {
        NSLog(@"Start Displaying...");
        [video_cell.playButton setHidden:YES];
        [video_cell.videoPlayer prepareToPlay];
    }
    
    [_visibleIndexs addObject:indexPath];
}
*/
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LocalChat *chatItem = self.localChats[indexPath.row];
    
    
    static NSString *identifier1 = @"cellMessage";
    static NSString *identifier2 = @"cellMessageAndPhoto";
//    static NSString *identifier3 = @"cellMessageAndVideo";
    
    NSString *cellID =  chatItem.photo.length == 0 ? identifier1 : identifier2;
    cellID = chatItem.videoLink.length > 0 ? identifier2 : cellID;
        
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor whiteColor];// (indexPath.row % 2 == 0) ? rgbColor(248.0, 248.0, 248.0) : [UIColor whiteColor];
    
    if (chatItem.videoLink.length > 0)
        [cell.playButton removeFromSuperview];
    
    [cell setChatItem:chatItem];
    
    if (chatItem.videoLink.length > 0) {
        NSLog(@">>>>%f>>>>%f", cell.imgViewPanorama.frame.size.width, cell.imgViewPanorama.frame.size.height);
        cell.playButton.hidden = NO;
        [cell.playButton setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        [cell.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cell.playButton];
        [cell.contentView bringSubviewToFront:cell.playButton];
    }
    else
        cell.playButton.hidden = YES;
    
    cell.delegate = self;
    
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatTableViewCell *video_cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (video_cell.videoPlayer != nil && ![_playedIndexs containsObject:indexPath]) {
        NSLog(@"End Displaying...");
        [video_cell.playButton setHidden:NO];
        [[video_cell.videoPlayer player] pause];
    }
 
}
 */

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
    if (self.stadium) {
        [self getStadiumChats];
    } else {
        [self getLocalChats];
    }
}

- (void)getLocalChats
{
    User *currentuser = [[Engine sharedEngine] settingManager].user;
    CLLocation *chatLocation = [currentuser getLocation];
    
    [[[Engine sharedEngine] dataManager] getLocalchatForLocation:chatLocation
                                                    withCallBack:^(BOOL success, id result, NSString *errorInfo)
     {
        if (success) {
            NSLog(@"Result %@",result);
            [self updateTableWithChats:result];
        }
         
         NSLog(@"%@>>%@", errorInfo, result);
    }];
}

- (void)getStadiumChats
{
    CLLocation *chatLocation = [self.stadium getLocation];
    
    [[[Engine sharedEngine] dataManager] getStadiumChatForLocation:chatLocation
                                                      withCallBack:^(BOOL success, id result, NSString *errorInfo)
     {
         if (success) {
             NSLog(@"Result %@",result);
             [self updateTableWithChats:result];
         }
     }];
}

- (void)updateTableWithChats:(NSArray *)chats
{
    NSArray *sortedArray = [chats sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        LocalChat *chatItem1 = obj1;
        LocalChat *chatItem2 = obj2;
                
        return [chatItem2.dateCreated compare:chatItem1.dateCreated];
    }];
    
    self.localChats = [NSMutableArray arrayWithArray:sortedArray];
    
    [self.tblView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void)addNewLocalChat
{
    NSString *message = self.textView.text;
    
    CLLocation *location = [self.stadium getLocation];
    if (!location) {
        User *currentuser = [[Engine sharedEngine] settingManager].user;
        location = [currentuser getLocation];
    }
    
 //   _videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://169.55.213.102/uploads/videos/1450801908_pf_movie.mov"]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
        
        [[[Engine sharedEngine] dataManager] createNewLocalchatForLocation:location
                                                                        withReplyID:self.replyID
                                                                            message:message
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
             
             NSLog(@"i m done");
         }];
    }
    
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
    LocalChat *localChat = (LocalChat *)chatItem;
    [[[Engine sharedEngine] dataManager] reportChatWithID:localChat.chatId forChatType:@"Geo Chat" withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            [self showSuccessMessage:result];
        } else {
            [self showErrorMessage:errorInfo];
        }
    }];
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
            
            NSString *stadium_name = @"";
            if (self.stadium)
                stadium_name = [NSString stringWithFormat:@"at %@ ", self.stadium.name];
            
            NSString *message = [NSString stringWithFormat:@"%@ (%@via pfan.co app)", localChat.message, stadium_name];
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

- (void)checkIfFarAway
{
    // CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    
    if (self.stadium) {
        
        self.vidCameraButton.hidden = YES;
        
        CLLocation *stadiumLocation = [self.stadium getLocation];
        
        User *currentuser = [[Engine sharedEngine] settingManager].user;
        CLLocation *userLocation = [currentuser getLocation];
        
        CLLocationDistance meters = [userLocation distanceFromLocation:stadiumLocation];
        
        NSLog(@"meters: %f",meters);
        
        if (meters > 400) {
            self.cameraButton.hidden = YES;
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
/*
- (void) changeToPlay {
    
    [[_moviePlayer.view viewWithTag:77] removeFromSuperview];
    
    UIButton *pausebtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-15, self.view.frame.size.height-50, 30, 30)];
    [pausebtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
    [pausebtn addTarget:self action:@selector(pauseVideo)
       forControlEvents:UIControlEventTouchUpInside];
    pausebtn.tag = 99;
    
    [_moviePlayer.view addSubview: pausebtn];
    [_moviePlayer.view bringSubviewToFront: pausebtn];
    
}

- (void) changeToPause {
    
    [[_moviePlayer.view viewWithTag:99] removeFromSuperview];
    
    UIButton *playbtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-15, self.view.frame.size.height-50, 30, 30)];
    [playbtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    [playbtn addTarget:self action:@selector(playVideo)
      forControlEvents:UIControlEventTouchUpInside];
    playbtn.tag = 77;
    
    [_moviePlayer.view addSubview: playbtn];
    [_moviePlayer.view bringSubviewToFront: playbtn];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([_moviePlayer.player rate]) {
            [self changeToPause];
        }
        else {
            [self changeToPlay];
        }
    }
}
*/


- (void) videoPlayerFinishPlaying:(NSNotification*)notification {
  
    NSLog(@"its called");
    AVPlayerItem *player = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:player];
    [self closeBigPlayer];
  //  [player seekToTime:kCMTimeZero];
   /* CGPoint pointInTable = [[player superclass] convertPoint:[player.view superview].bounds.origin toView:_tblView];
    NSIndexPath *indexPath = [_tblView indexPathForRowAtPoint:pointInTable];
    ChatTableViewCell *video_cell = [_tblView cellForRowAtIndexPath:indexPath];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    
    LocalChat *chatItem = self.localChats[indexPath.row];
    
    [video_cell.playButton removeFromSuperview];
    video_cell.videoView = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:chatItem.videoLink] options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *thumbnail = [[UIImage alloc] initWithCGImage:oneRef];
        
        UIImageView *thumbView = [[UIImageView alloc]  initWithImage:thumbnail];
        [thumbView setFrame:CGRectMake(0, 0, video_cell.videoView.frame.size.width, video_cell.videoView.frame.size.height)];
        thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [thumbView setImage:thumbnail];
        
        [video_cell.videoPlayer.view removeFromSuperview];
        [video_cell.videoView addSubview:thumbView];
        
        [video_cell.playButton setFrame:CGRectMake((video_cell.videoView.frame.size.width/2)-18, 67, 36, 36)];
        [video_cell.videoView addSubview:video_cell.playButton];
        video_cell.playButton.hidden = NO;
    });
    
    [_playedIndexs addObject:indexPath];*/
}

- (void) closeBigPlayer {
    
        [[_moviePlayer player] setRate:0.0];
//        [[self.view viewWithTag:88] removeFromSuperview];
        [_moviePlayer.view removeFromSuperview];
        _moviePlayer = nil;
}


- (BOOL)isIndexPathVisible:(NSIndexPath*)indexPath
{
    NSArray *visiblePaths = [_tblView indexPathsForVisibleRows];
    
    for (NSIndexPath *currentIndex in visiblePaths)
    {
        NSComparisonResult result = [currentIndex compare:currentIndex];
        
        if(result == NSOrderedSame)
        {
            NSLog(@"Visible %ld", (long)indexPath.row);
            return YES;
        }
/*        else {
            [cell.playButton setHidden:NO];
            NSLog(@"Not Visible %ld", (long)indexPath.row);
        }*/
    }
    
    return NO;
}


@end
