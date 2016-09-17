//
//  PhotoManager.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/15/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PhotoResultBlock)(UIImage *image);

@interface PhotoManager : NSObject

- (void)selectPhotoFromController:(UIViewController *)controller withCompletition:(PhotoResultBlock)completition;
- (void)selectCameraFromController:(UIViewController *)controller withCompletition:(PhotoResultBlock)completition;
- (void)selectAlbumFromController:(UIViewController *)controller withCompletition:(PhotoResultBlock)completition;

@end
