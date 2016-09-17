//
//  PhotoManager.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/15/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "PhotoManager.h"
#import <UIAlertView+Blocks.h>

@interface PhotoManager()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, copy) PhotoResultBlock completition;

@end

@implementation PhotoManager

- (void)selectPhotoFromController:(UIViewController *)controller withCompletition:(PhotoResultBlock)completition
{
    self.controller = controller;
    self.completition = completition;
    
    NSString *camera = @"Take photo";
    NSString *album = @"Access album";
    
    NSMutableArray *photoSources = [NSMutableArray arrayWithCapacity:2];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [photoSources addObject:camera];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [photoSources addObject:album];
    }
    
    if (photoSources.count == 0) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera and access to album"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    } else {
        [UIAlertView showWithTitle:@"Photo Upload"
                           message:@"How would you like to upload your photo?"
                 cancelButtonTitle:@"Cancel"
                 otherButtonTitles:photoSources
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  self.completition(nil);
                              } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:camera]) {
                                  [self showPhotoPopup];
                              } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:album]) {
                                  [self showAlbumPopup];
                              }
                          }];
    }
}

- (void)selectCameraFromController:(UIViewController *)controller withCompletition:(PhotoResultBlock)completition
{
    self.controller = controller;
    self.completition = completition;
    
    [self showPhotoPopup];
}

- (void)selectAlbumFromController:(UIViewController *)controller withCompletition:(PhotoResultBlock)completition
{
    self.controller = controller;
    self.completition = completition;
    
    [self showAlbumPopup];
}

- (void)showPhotoPopup
{
    [self showPopoverWithSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)showAlbumPopup
{
    [self showPopoverWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)showPopoverWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = sourceType;
 
 /*   if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        CGRect f = picker.view.bounds;
        f.size.height -= picker.navigationBar.bounds.size.height;
        UIGraphicsBeginImageContext(f.size);
        [[UIColor colorWithWhite:0 alpha:1.0] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, 124.0), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, 124+f.size.width, f.size.width, 100-(f.size.width-320)), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
        overlayIV.image = overlayImage;
        overlayIV.alpha = 1.0f;
        
        [picker setCameraOverlayView:overlayIV];
    
    }
  */
    
    [self.controller presentViewController:picker animated:YES completion:NULL];
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    chosenImage = [self scaleAndRotateImage:chosenImage];
    
    chosenImage = [self imageByCroppingImage:chosenImage toSize:CGSizeMake(picker.view.frame.size.width, picker.view.frame.size.width)];
    
    chosenImage = [self compressForUpload:chosenImage scale:0.3];
 
    if (self.completition) {
        self.completition(chosenImage);
    }    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.completition) {
        self.completition(nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/// Helper

- (UIImage *) scaleAndRotateImage: (UIImage *)image
{
    int kMaxResolution = 3000; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),      CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double newCropWidth, newCropHeight;
    
    //=== To crop more efficently =====//
    if(image.size.width < image.size.height){
        if (image.size.width < size.width) {
            newCropWidth = size.width;
        }
        else {
            newCropWidth = image.size.width;
        }
        newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
        if (image.size.height < size.height) {
            newCropHeight = size.height;
        }
        else {
            newCropHeight = image.size.height;
        }
        newCropWidth = (newCropHeight * size.width)/size.height;
    }
    //==============================//
    
    double x = image.size.width/2.0 - newCropWidth/2.0;
    double y = image.size.height/2.0 - newCropHeight/2.0;
    
    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

@end
