//
//  CustomDropDownCell.h
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomDropDownCell <NSObject>

- (UITableViewCell *)customCellForIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) customNumberOfRowsInSection:(NSInteger)section;
- (NSArray *)fillteredItemsWithString:(NSString *)filterString;
- (NSArray *)fillteredItemsWithString:(NSString *)filterString withArray:(NSMutableArray *)sourceArray;

@end
