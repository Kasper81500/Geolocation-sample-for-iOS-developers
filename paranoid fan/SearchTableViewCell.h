//
//  SearchTableViewCell.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/10/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchItem.h"

@interface SearchTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *iconWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *iconHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *iconTop;

@property (nonatomic, weak) id<SearchItem> pin;

@end
