//
//  FavoriteTableViewCell.h
//  paranoid fan
//
//  Created by Adeel Asim on 3/25/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pin.h"

@interface FavoriteTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) Pin *pin;

@end
