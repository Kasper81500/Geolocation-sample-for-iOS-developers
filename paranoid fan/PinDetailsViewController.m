//
//  PinDetailsViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "PinDetailsViewController.h"
#import "Engine.h"
#import "Pin.h"
#import "User.h"
#import "PinChatItem.h"
#import "UIImageView+AFNetworking.h"
#import "PopupTableViewCell.h"
#import "TipViewController.h"
#import "Constants.h"
#import <GrowingTextViewHandler.h>
#import "LocalChat.h"
#import "UIViewController+Popup.h"
#import "PhotoManager.h"
#import "MBProgressHUD.h"
#import "NSDate+TimeAgo.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>


#define kSeguetipView        @"tipView"

@import MediaPlayer;

@interface PinDetailsViewController ()<UITableViewDataSource, UITableViewDelegate, PopupTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewForPopup;
@property (weak, nonatomic) PinChatItem *pinChatItem;

@property (nonatomic, strong) NSMutableArray *chatItems;
@property (nonatomic, strong) UIImage *createdChatPhoto;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *vidCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (nonatomic, weak) IBOutlet UIImageView *pinIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamLabel;
@property (nonatomic, weak) IBOutlet UILabel *address;
@property (nonatomic, weak) IBOutlet UILabel *dateTime;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UIButton *directionButton;
@property (nonatomic, weak) IBOutlet UIButton *favorite;
@property (nonatomic, weak) IBOutlet UIImageView *verified;
@property (nonatomic, weak) IBOutlet UIImageView *rating1;
@property (nonatomic, weak) IBOutlet UIImageView *rating2;
@property (nonatomic, weak) IBOutlet UIImageView *rating3;
@property (nonatomic, weak) IBOutlet UIImageView *rating4;
@property (nonatomic, weak) IBOutlet UIImageView *rating5;

@property (strong, nonatomic) GrowingTextViewHandler *handler;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *teamLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) PhotoManager *photoManager;

@property (nonatomic) NSInteger replyID;

/***** Video Recording ****/
@property (nonatomic, strong) UIImagePickerController *picker;
@property (strong, nonatomic) AVPlayerViewController *moviePlayer;
@property (nonatomic, retain) NSURL *recordedVideoPath;
@property (nonatomic,retain) NSMutableData *videoData;
@property (nonatomic) BOOL isRecording;
@property (nonatomic, strong) NSMutableArray *playedIndexs;
@property (nonatomic, retain) NSTimer *videoTimer;

@end

@implementation PinDetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewForPopup.hidden = YES;
    self.chatItems = [NSMutableArray array];
    
    self.titleLabel.text = self.pin.mapPinTitle;
    
    NSComparisonResult result = [[NSDate date] compare:self.pin.dateCreated];
    
    if (result == NSOrderedAscending) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM d, hh:mm a"];
        NSString *dateString = [dateFormatter stringFromDate:self.pin.dateCreated];
        self.dateTime.text = [NSString stringWithFormat:@"%@", dateString];
    }
    else
        self.dateTime.text = [self.pin.dateCreated timeAgo];
    
    self.distanceLabel.text = self.pin.distance;
    
    if (self.pin.userID != [[Engine sharedEngine] settingManager].userID)
        self.removeButton.hidden = YES;
    
    NSString *mapPinType = [self.pin mapPinType];
    NSString *mapPinTags = [self.pin getSearchTags];
    NSString *pinImage = nil;
    
    if ([mapPinType isEqualToString:@"Beer"]) {
        
        pinImage = [mapPinType stringByAppendingFormat:@"_%@", mapPinTags];
        
        if ([UIImage imageNamed:pinImage] == nil)
            pinImage = [NSString stringWithFormat:@"menu_v2_%@",mapPinType];
    }
    else
        pinImage = [NSString stringWithFormat:@"menu_v2_%@",mapPinType];
    
    UIImage *pinImageMarker = [UIImage imageNamed:pinImage];
    self.pinIconImageView.image = pinImageMarker;
    _iconWidthConstraint.constant = pinImageMarker.size.width;
    _iconLeftConstraint.constant = 0;
    
    if (![mapPinTags isEqualToString:@""] && mapPinTags != nil && ![mapPinTags isEqualToString:@"(null)"]) {
        
        mapPinTags = [@"Team: " stringByAppendingString:mapPinTags];
        
        NSDictionary *initialAttributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                             NSFontAttributeName : [UIFont fontWithName:@"Roboto-Regular" size:13.0] };
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:mapPinTags attributes:initialAttributes];
        NSRange range = [mapPinTags rangeOfString:@"Team:"];
        
        NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                          NSFontAttributeName : [UIFont fontWithName:@"Roboto-Bold" size:13.0] };
        
        [attributedString setAttributes:linkAttributes range:range];
        
        self.teamLabel.attributedText = attributedString;
        self.teamLabelHeightConstraint.constant = 20;
    }
    else {
        self.teamLabel.text = @"";
        self.teamLabelHeightConstraint.constant = 2;
    }
    
    self.tableView.delaysContentTouches = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 118.0;
    self.replyID = 0;
    
    self.titleLabel.preferredMaxLayoutWidth = 198;
    self.verified.hidden = YES;
    
    self.topViewHeightConstraint.constant = 95;
    
    if (self.pin.mapPinCoverPhoto != nil) {
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: self.pin.mapPinCoverPhoto]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithData: data]];
            });
        });
    
        self.topViewHeightConstraint.constant = 180;
        self.topViewTopConstraint.constant = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.teamLabel.textColor = [UIColor whiteColor];
        self.distanceLabel.textColor = [UIColor whiteColor];
        self.dateTime.textColor = [UIColor whiteColor];
    }
    
    NSLog(@"self.pin.isVerified %@", self.pin.isVerified);
    if ([self.pin.isVerified isEqualToString:@"Yes"]) {
        self.verified.hidden = NO;
    }
    
 //   UIView *topPanel = (UIView *)[self.view viewWithTag:234];
    CGSize mainViewSize = self.topView.bounds.size;
    CGFloat borderHeight = 1;
    UIColor *borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topViewHeightConstraint.constant-1, mainViewSize.width, borderHeight)];
    bottomView.backgroundColor = borderColor;
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.topView addSubview:bottomView];
    
    if (self.pin.mapAddress != nil && self.pin.mapAddress != NULL && ![self.pin.mapAddress isEqualToString:@"(null)"] && ![self.pin.mapAddress isEqualToString:@""])
        self.address.text = self.pin.mapAddress;
    else {
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[self.pin getLocation] completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(placemarks && placemarks.count > 0)
             {
                 CLPlacemark *placemark= [placemarks objectAtIndex:0];
                 
                 if ([placemark subThoroughfare] == nil || [placemark thoroughfare] == nil || [placemark subThoroughfare] == NULL || [placemark thoroughfare] == NULL)
                     self.address.text = @"Exact address unavailable";
                 else
                     self.address.text = [NSString stringWithFormat:@"%@ %@, %@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
                 self.pin.mapAddress = self.address.text;
                 NSLog(@"Current Address: %@", self.address);
             }
             
         }];
    }
    
    [self setupRating];
    
    [self setupFavorite];
    
    [self loadChatForPin:self.pin];
    //[self setupDirectionButton];
    
    self.handler = [[GrowingTextViewHandler alloc]initWithTextView:self.textView withHeightConstraint:self.heightConstraint];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    TipViewController *tipVC = segue.destinationViewController;
    tipVC.pinChatItem = self.pinChatItem;
}

- (void) setupFavorite {
    
    if(self.pin.isFavorite)
        self.favorite.selected = YES;
    else
        self.favorite.selected = NO;
}


- (void) setupRating {
    
    if (self.pin.rated)
        [self closeRating:self];
    
    UIView *ratingView = (UIView *)[self.view viewWithTag:999];
    CGSize mainViewSize = ratingView.bounds.size;
    CGFloat borderHeight = 1;
    UIColor *borderColor = [UIColor lightGrayColor];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, mainViewSize.height-1, mainViewSize.width, borderHeight)];
    bottomView.opaque = YES;
    bottomView.backgroundColor = borderColor;
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [ratingView addSubview:bottomView];
    
    [self updateRating];
}

- (void) updateRating {
    
    if (self.pin.rating == 1) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (self.pin.rating == 2) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (self.pin.rating == 3) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (self.pin.rating == 4) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (self.pin.rating == 5) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_fill"]];
    }
    else {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
}

- (void)setupDirectionButton
{
    self.directionButton.layer.cornerRadius = 2.0;
    self.directionButton.layer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_signup"]].CGColor;
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



#pragma mark - Notifications

- (void)keyboardWasShown:(NSNotification *)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = keyboardSize.height - 56; // small hardcode :-( this is height of bottom menu
}
- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}


#pragma mark - Table


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatItems.count;
}

- (UITableViewCell* ) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    PinChatItem *chatItem = self.chatItems[indexPath.row];
    
    
    static NSString *identifier1 = @"cellMessage";
    static NSString *identifier2 = @"cellMessageAndPhoto";
//    static NSString *identifier3 = @"cellMessageAndVideo";
    
    NSString *cellID =  chatItem.photo.length == 0 ? identifier1 : identifier2;
    cellID =  chatItem.videoLink.length > 0 ? identifier2 : cellID;
    
    NSLog(@"row %zd = %@",indexPath.row,cellID);
    
    PopupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor whiteColor]; //(indexPath.row % 2 == 0) ? rgbColor(248.0, 248.0, 248.0) :
    
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
    
    PopupTableViewCell *video_cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (video_cell.videoPlayer != nil && ![_playedIndexs containsObject:indexPath]) {
        NSLog(@"End Displaying...");
        [video_cell.playButton setHidden:NO];
  //      [video_cell.videoPlayer pause];
    }
    
}
*/
#pragma mark - Actions

- (IBAction)likeSpot:(id)sender {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIButton* btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        
        [[[Engine sharedEngine] dataManager] addFavorite:self.pin.pinID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                
                self.pin.isFavorite = TRUE;
                
                [self setupFavorite];
            } else {
                
                [self showErrorMessage:errorInfo];
            }
        }];
    }
    else {
        
        [[[Engine sharedEngine] dataManager] removeFavorite:self.pin.pinID withCallBack:^(BOOL success, id result, NSString *errorInfo) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                
                self.pin.isFavorite = NO;
                
                [self setupFavorite];
                
            } else {
                
                [self showErrorMessage:errorInfo];
            }
        }];
    }
}

- (IBAction)cameraClicked:(id)sender {

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
            self.createdChatPhoto = image;
            self.cameraButton.selected = YES;
        } else {
            self.createdChatPhoto = nil;
            self.cameraButton.selected = NO;
        }
    }];
}

- (void) removePin {
    
    [[[Engine sharedEngine] dataManager] deletePin:self.pin.pinID
                                              withCallBack:
     ^(BOOL success, id result, NSString *errorInfo) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (success) {
             
             [self.delegate removePin:self withPin:self.pin];

         } else {
             [self showErrorMessage:errorInfo];
         }
     }];

}

- (IBAction)clickVideoCam:(id)sender {

    
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

- (IBAction)sendClicked:(id)sender
{
    NSString *message = self.textView.text;
    
    [self addNewChatMessage:message photo:self.createdChatPhoto forPin:self.pin];
}

- (IBAction)clickTwitter:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)clickDirection:(id)sender
{
    CLLocation *userLocation = [[[[Engine sharedEngine] settingManager] user] getLocation];
    CLLocationCoordinate2D pinCoords = [self.pin getLocationCoordinate];
    
    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude, pinCoords.latitude, pinCoords.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString]];
}

- (IBAction)clickRemove:(id)sender {
    
    NSString *yes = @"Yes";
    
    NSMutableArray *photoSources = [NSMutableArray arrayWithCapacity:1];
    [photoSources addObject:yes];
    
    [UIAlertView showWithTitle:@"Remove Pin"
                       message:@"Are you sure you want to remove this pin?"
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:photoSources
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              //self.completition(nil);
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:yes]) {
                              [self removePin];
                          }
                      }];

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

#pragma mark - UIImagePicker Delegate Methods


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.videoTimer invalidate];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
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
   // [btn setSelected:YES];
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
    
    [self.videoTimer invalidate];
    
}

#pragma mark - Video Recording Support

- (NSURL*)grabFileURL:(NSString *)fileName {
    
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    return documentsURL;
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
    PinChatItem *pinChat = (PinChatItem *)chatItem;
    [[[Engine sharedEngine] dataManager] reportChatWithID:pinChat.pinChatId forChatType:@"Pin Chat" withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            [self showSuccessMessage:result];
        } else {
            [self showErrorMessage:errorInfo];
        }
    }];
}

- (void)popupTableViewCell:(PopupTableViewCell *)cell likeChatItem:(id<ChatItem>)chatItem
{
    PinChatItem *pinChat = (PinChatItem *)chatItem;
    
    [[[Engine sharedEngine] dataManager] likePinChatWithID:pinChat.pinChatId withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"liked");
            pinChat.liked = TRUE;
        }
    }];
}

- (void)popupTableViewCell:(PopupTableViewCell *)cell dislikeChatItem:(id<ChatItem>)chatItem
{
    PinChatItem *pinChat = (PinChatItem *)chatItem;
    
    [[[Engine sharedEngine] dataManager] dislikePinChatWithID:pinChat.pinChatId withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            pinChat.liked = FALSE;
            NSLog(@"disliked");
        }
    }];
}

- (void)popupTableViewCell:(PopupTableViewCell *)cell tipChatItem:(id<ChatItem>)chatItem
{
    PinChatItem *pinChat = (PinChatItem *)chatItem;
    self.pinChatItem = pinChat;
    
    self.viewForPopup.hidden = NO;
    [self.view bringSubviewToFront:self.viewForPopup];
    [self performSegueWithIdentifier:kSeguetipView sender:self];
}


#pragma mark - Private method

- (void)loadChatForPin:(Pin *)pin
{
    [[[Engine sharedEngine] dataManager] getAllChatItemsForPinID:pin.pinID
                                                    withCallBack:^(BOOL success, id result, NSString *errorInfo)
     {
         if (success) {
             NSArray *messages = (NSArray *)result;
             NSArray *sortedArray = [messages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                 LocalChat *chatItem1 = obj1;
                 LocalChat *chatItem2 = obj2;
                 
                 return [chatItem2.dateCreated compare:chatItem1.dateCreated];
             }];
             
             self.chatItems = [NSMutableArray arrayWithArray:sortedArray];
             [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
         }
     }];
}

- (void)addNewChatMessage:(NSString *)message photo:(UIImage *)photo forPin:(Pin *)pin
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.cameraButton.isSelected)
        _videoData = [[NSMutableData alloc] initWithContentsOfURL:_recordedVideoPath];

    if (_videoData != nil) {
        
        self.cameraButton.selected = NO;

        [[[Engine sharedEngine] dataManager] addChatItemForPin:pin withReplyID:self.replyID
                                                   withMessage:message
                                                         photo:photo
                                                     withVideo:_videoData
                                                   andLocation:[[Engine sharedEngine].settingManager.user getLocation]
                                                  withCallBack:
         ^(BOOL success, id result, NSString *errorInfo) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                // PinChatItem *chat = (PinChatItem *)result;
                // [self postTweetForPinChat:chat];
                 [self.chatItems insertObject:result atIndex:0];
                 [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
             } else {
                 [self showErrorMessage:errorInfo];
             }
         }];
        
        _videoData = nil;
    }
    else {
        
        [[[Engine sharedEngine] dataManager] addChatItemForPin:pin withReplyID:self.replyID
                                                   withMessage:message
                                                         photo:photo
                                                   andLocation:[[Engine sharedEngine].settingManager.user getLocation]
                                                  withCallBack:
         ^(BOOL success, id result, NSString *errorInfo) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             if (success) {
                // PinChatItem *chat = (PinChatItem *)result;
                // [self postTweetForPinChat:chat];
                 [self.chatItems insertObject:result atIndex:0];
                 [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
             } else {
                 [self showErrorMessage:errorInfo];
             }
         }];
    }
    
    [self resetUI];
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

- (void)postTweetForPinChat:(PinChatItem *)localChat
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

- (IBAction)shareLink:(id)sender {
    
    CLLocationCoordinate2D pinCoords = [self.pin getLocationCoordinate];
    
    NSString *shareString = [NSString stringWithFormat:@"http://paranoidfan.com/meetme.php?type=%@&latittude=%f&longitude=%f&pid=%ld", [[self.pin getPinType] stringByReplacingOccurrencesOfString:@" " withString:@"_"], pinCoords.latitude, pinCoords.longitude, self.pin.pinID];
    
    NSURL *url = [[NSURL alloc] initWithString:shareString];
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:url];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                         NSLog(@"completed.");
                     }];
}

- (void)resetUI
{
    self.cameraButton.selected =
    self.twitterButton.selected = NO;
    
    self.createdChatPhoto = nil;
    [self.handler setText:nil withAnimation:YES];
    
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - rating

- (IBAction)closeRating:(id)sender
{
    [[self.view viewWithTag:999] removeFromSuperview];
}

- (IBAction)saveRating:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIButton* btn = (UIButton *)sender;
    
    for (int i=101; i <= btn.tag; i++) {
        
        UIButton* btn_highlighted = (UIButton *)[self.view viewWithTag:i];
        [btn_highlighted setSelected:YES];
    }
    
    //sleep(1);
    
    NSInteger rating = btn.tag - 100;
    
    [[[Engine sharedEngine] dataManager] saveRatingForPin:self.pin withRating:rating withCallBack:^(BOOL success, id result, NSString *errorInfo) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
                self.pin.rated = true;
                self.pin.rating = self.pin.rating == 0 ? rating : (self.pin.rating + rating)/2;
                sleep(1);
                [self closeRating:sender];
                [self updateRating];
            
            } else {
            
                [self showErrorMessage:errorInfo];
        }
    }];
    
    
}


#pragma mark - video playing mehtods
- (void) playVideo:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    
    PinChatItem *chatItem = self.chatItems[indexPath.row];
    
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
    
    [self.view bringSubviewToFront:_moviePlayer.view];
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
    NSArray *visiblePaths = [_tableView indexPathsForVisibleRows];
    
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
