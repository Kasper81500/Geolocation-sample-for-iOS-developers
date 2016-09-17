//
//  PopupTableViewCell.m
//  paranoid fan
//
//  Created by Ferenc Knebl on 01/09/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "PopupTableViewCell.h"
#import "PinChatItem.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+TimeAgo.h"
#import "ChatItem.h"

@interface PopupTableViewCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageWidthConstraint;


@end

@implementation PopupTableViewCell

- (void)setChatItem:(id<ChatItem>)chatItem
{
    BOOL isAttributed = NO;
    _chatItem = chatItem;
    
    self.imgViewProfile.layer.masksToBounds = YES;
    self.imgViewProfile.layer.cornerRadius = self.imgViewProfile.frame.size.width/2;
    
    self.lblName.text = chatItem.profileName;

    NSString *attrString = chatItem.message;
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detect matchesInString:attrString options:0 range:NSMakeRange(0, [attrString length])];
    
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {

            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:attrString attributes:nil];
            NSRange linkRange = match.range;
            
            NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone) };
            [attributedString setAttributes:linkAttributes range:linkRange];
            
            // Assign attributedText to UILabel
            self.lblMessage.attributedText = attributedString;
            
            self.lblMessage.userInteractionEnabled = YES;
            [self.lblMessage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
            
            isAttributed = YES;
        }
    }

    if (!isAttributed)
        self.lblMessage.text = chatItem.message;
    
    [self.imgViewProfile setImageWithURL:[NSURL URLWithString:self.chatItem.avatar]];

    self.lblTime.text = [[self.chatItem dateCreated] timeAgo];
    
    [self setupHeart];
    
    self.imgViewPanorama.image = nil;

    if (self.chatItem.photo.length > 0 || self.chatItem.videoLink.length > 0) {
        
        CGFloat currentWidth = 404;
        if ([UIScreen mainScreen].bounds.size.width == 375)
            currentWidth = 365;
        else if ([UIScreen mainScreen].bounds.size.width == 320)
            currentWidth = 310;
        
        NSLog(@"current Width: %f", currentWidth);
        NSLog(@"View Width: %f", self.btnHeart.frame.origin.x);
        CGFloat newImageHeight = 0;
        CGFloat newImageWidth = 0;
        CGFloat imageWidth = 0;
        CGFloat imageHeight = 0;
        
        if (self.chatItem.photo.length > 0) {
            NSLog(@"Is Photo: %@", self.chatItem.photo);
            imageWidth = [chatItem imageWidth];
            imageHeight = [chatItem imageHeight];
        }
        else if (self.chatItem.videoLink.length > 0) {
            
            NSLog(@"Is Video: %@", self.chatItem.videoLink);
            imageWidth = [chatItem imageWidth];
            imageHeight = [chatItem imageHeight];
        }
        else {
            NSLog(@"Nothing");
            imageWidth = 800;
            imageHeight = 452;
        }
        
        float ratio = 0;
        
    /*    if (currentWidth > imageWidth) {
            ratio = imageWidth / currentWidth;
            newImageHeight = imageHeight / ratio;
        }
        else {*/
            ratio = currentWidth / imageWidth;
            newImageHeight = ratio * imageHeight;
       // }
        
        newImageHeight = ratio * imageHeight;
        newImageWidth = currentWidth;
        NSLog(@"New Height: %f", newImageHeight);
        
        if (newImageHeight != newImageHeight) {
            self.imageHeightConstraint.constant = 0;
            NSLog(@"Is it nan");
        }
        else
            self.imageHeightConstraint.constant = newImageHeight;
        
       // if (imageHeight > imageWidth) {
        
        
     //   }
       // else {
            
        //    CGFloat currentHeight = CGRectGetHeight(self.imgViewPanorama.bounds);
        //    newImageWidth = currentHeight * imageWidth / imageHeight;
        //    newImageHeight = currentWidht * imageWidth / imageHeight;
        //    self.imageWidthConstraint.constant = newImageWidth;
       // }
        
        if (self.chatItem.videoLink.length > 0 && newImageHeight == newImageHeight) {
            NSLog(@">>>>>>%@", self.chatItem.videoLink);
            NSString *thumb_link = [self.chatItem.videoLink stringByReplacingOccurrencesOfString:@"videos/" withString:@"videos/thumbnails/"];
            thumb_link = [thumb_link stringByReplacingOccurrencesOfString:@".mp4" withString:@"_thumb.png"];
            
            [self.imgViewPanorama setImageWithURL:[NSURL URLWithString:thumb_link]];
            self.playButton = [[UIButton alloc] initWithFrame:CGRectMake((newImageWidth/2)-18, self.imgViewPanorama.frame.origin.y+(newImageHeight/2)-18, 36, 36)];
        }
        else
            [self.imgViewPanorama setImageWithURL:[NSURL URLWithString:self.chatItem.photo]];
    }
   /* else if (self.chatItem.videoLink.length > 0) {
        
        self.imageWidthConstraint.constant = currentWidth;
        NSString *thumb_link = [chatItem.videoLink stringByReplacingOccurrencesOfString:@"videos/" withString:@"videos/thumbnails/"];
        thumb_link = [thumb_link stringByReplacingOccurrencesOfString:@".mp4" withString:@"_thumb.png"];
        
        UIImageView *thumbView = [[UIImageView alloc]  init];
        [thumbView setImageWithURL:[NSURL URLWithString:thumb_link]];
        [thumbView setFrame:CGRectMake(0, 0, self.videoView.frame.size.width, self.videoView.frame.size.height)];
        thumbView.contentMode = UIViewContentModeScaleAspectFit;
        [thumbView setBackgroundColor:[UIColor blackColor]];
        [self.videoView addSubview:thumbView];
        
        //      cell.videoView.autoresizesSubviews = YES;
    }*/
    
    /*
    __block PopupTableViewCell *weakSelf = self;
    if (self.chatItem.photo.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.chatItem.photo]];
            UIImage *image = [UIImage imageWithData:imageData];
            
            if (image) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.imgViewPanorama.image = image;
                    [self setNeedsDisplay];
                });
            }
        });
    }
     */
    
    
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)setupHeart
{
    NSInteger count = self.chatItem.likeCount;
    
    NSString *heartImage;
    NSString *heartImageSelected;
    
    if (count <= 10) {
        heartImage = @"heartLow";
        heartImageSelected = @"heartLowLiked";
    } else if (count > 10 && count <=25) {
        heartImage = @"heartMid";
        heartImageSelected = @"heartMidLiked";
    } else {
        heartImage = @"heartHigh";
        heartImageSelected = @"heartHighLiked";
    }
    
    [self.btnHeart setBackgroundImage:[UIImage imageNamed:heartImage] forState:UIControlStateNormal];
    [self.btnHeart setBackgroundImage:[UIImage imageNamed:heartImageSelected] forState:UIControlStateHighlighted];
    [self.btnHeart setBackgroundImage:[UIImage imageNamed:heartImageSelected] forState:UIControlStateSelected];
    
    self.btnHeart.selected = self.chatItem.liked;
}

#pragma mark - IBAction

- (IBAction)report:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupTableViewCell:didReportForChatItem:)]) {
        [self.delegate popupTableViewCell:self didReportForChatItem:self.chatItem];
    }
}

- (IBAction)reply:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupTableViewCell:didReplyForChatItem:)]) {
        [self.delegate popupTableViewCell:self didReplyForChatItem:self.chatItem];
    }
}

- (IBAction)like:(UIButton *)sender
{
    //sender.selected = !sender.selected;
    sender.selected = YES;
    
    if (self.delegate) {
       /* if (sender.selected && [self.delegate respondsToSelector:@selector(popupTableViewCell:likeChatItem:)]) {
            [self.delegate popupTableViewCell:self likeChatItem:self.chatItem];
        } else if (!sender.selected && [self.delegate respondsToSelector:@selector(popupTableViewCell:dislikeChatItem:)]) {
            [self.delegate popupTableViewCell:self dislikeChatItem:self.chatItem];
        }*/
        
        if ([self.delegate respondsToSelector:@selector(popupTableViewCell:likeChatItem:)]) {
            [self.delegate popupTableViewCell:self likeChatItem:self.chatItem];
        }
    }
}

- (IBAction)tip:(UIButton *)sender
{
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(popupTableViewCell:tipChatItem:)]) {
            [self.delegate popupTableViewCell:self tipChatItem:self.chatItem];
        } 
    }
}

#pragma mark - Gestures

- (void)handleTapOnLabel:(UITapGestureRecognizer *)tapGesture
{
    
    UILabel *label = (UILabel *) tapGesture.view;
    NSLog(@">>%@", label.text);
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detect matchesInString:label.text options:0 range:NSMakeRange(0, [label.text length])];
    
    for (NSTextCheckingResult *match in matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange linkRange = match.range;
           
            NSString *url = [label.text substringWithRange:linkRange];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            break;
        }
    }
    
    /*CGPoint locationOfTouchInLabel = [tapGesture locationInView:tapGesture.view];
    CGSize labelSize = tapGesture.view.bounds.size;
    CGRect textBoundingBox = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    NSInteger indexOfCharacter = [self.layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                            inTextContainer:self.textContainer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    NSRange linkRange = NSMakeRange(14, 4); // it's better to save the range somewhere when it was originally used for marking link in attributed string
    if (NSLocationInRange(indexOfCharacter, linkRange) {
        // Open an URL, or handle the tap on the link in any other way
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://stackoverflow.com/"]];
    }
     */
}

@end
