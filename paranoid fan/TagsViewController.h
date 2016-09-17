//
//  TagsViewController.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/16/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagsViewController;

@protocol TagsViewControllerDelegate <NSObject>

- (void)tagsViewController:(TagsViewController *)tagsVC didEndSelectingWithSize:(CGSize)tagsViewSize;
- (void)tagsViewController:(TagsViewController *)tagsVC didSelectedTags:(NSArray *)tags;
- (void)tagsViewController:(TagsViewController *)tagsVC didResize:(CGSize)tagsViewSize;

@end

@interface TagsViewController : UIViewController

@property (nonatomic, strong) UIColor *placeHolderColor;
@property (nonatomic, weak) id<TagsViewControllerDelegate> delegate;

@end
