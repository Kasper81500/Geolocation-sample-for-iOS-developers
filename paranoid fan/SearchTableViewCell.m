//
//  SearchTableViewCell.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/10/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "SearchTableViewCell.h"
#import "Pin.h"
#import "Stadium.h"

@interface SearchTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *pinLabel;
@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (nonatomic, weak) IBOutlet UIImageView *distancePin;
@property (nonatomic, weak) IBOutlet UILabel *pinDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelViewHeightConstraint;


@end

@implementation SearchTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
   // self.onePixelViewHeightConstraint.constant = 1.f/[UIScreen mainScreen].scale;//enforces it to be a true 1 pixel line
}

- (void)setPin:(id<SearchItem>)pin
{
  //  if ([pin isKindOfClass:[Pin class]]) {
        _pin = pin;
        
        NSString *title = [pin getSearchTitle];
        NSString *type = [pin getPinType];
        self.labelViewHeightConstraint.constant = 0;
    
        NSString *commonString = [NSString stringWithFormat:@"%@",title];
    
        [self.icon setImage:[UIImage imageNamed:@"city"]];
    
        self.iconWidth.constant = 30;
        self.iconHeight.constant = 30;
        self.iconTop.constant = -3;
    
        if (![type isEqualToString:@"Beer"] && ![type isEqualToString:@"Watch Party"] && ![type isEqualToString:@"Fan"]) {

            NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor]};
            NSDictionary *startAttrs = @{ NSForegroundColorAttributeName : [UIColor grayColor]};
            
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:commonString attributes:attrs];
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
            
            [mutableString setAttributes:startAttrs range:NSMakeRange(0, title.length)];
            
            [self.pinLabel setAttributedText:mutableString];
            
            if ([pin getDistance]) {
                
                [self.pinDistance setHidden:NO];
                [self.pinDistance setText:[pin getDistance]];
                [self.distancePin setHidden:NO];
                [self.icon setImage:[UIImage imageNamed:@"bottomBarVenue"]];
            }
            else {
                
                [self.pinDistance setHidden:YES];
                [self.distancePin setHidden:YES];
             //   [self.icon setImage:nil];
                
                self.labelViewHeightConstraint.constant = -8;
                
            }
        }
        else if ([type isEqualToString:@"Fan"]){
            
            commonString = [NSString stringWithFormat:@"%@ Fans",title];
            [self.pinLabel setText:commonString];
            [self.icon setImage:[UIImage imageNamed:@"social_icon"]];
            [self.pinDistance setHidden:YES];
            [self.distancePin setHidden:YES];
            
            self.labelViewHeightConstraint.constant = -8;
        }
        else if ([type isEqualToString:@"Beer"]){
            
            //NSString *title = [pin getSearchTags];
            
            NSString *pinImage = nil;
            
//            CGSize iconSize = CGSizeMake(10, 10);
            
            
            pinImage = [type stringByAppendingFormat:@"_%@", title];
            
            if ([UIImage imageNamed:pinImage] == nil)
                pinImage = type;
            
            UIImage *beerImage = [UIImage imageNamed:pinImage];
   //         beerImage = [self imageWithImage:beerImage scaledToSize:iconSize];
            commonString = [NSString stringWithFormat:@"%@ Bars",title];
            [self.pinLabel setText:commonString];
            
          //  self.icon.contentMode = UIViewContentModeScaleAspectFit;
            [self.icon setImage:beerImage];
            
            self.iconWidth.constant = 24;
            self.iconHeight.constant = 24;
            self.iconTop.constant = 3;

                        
            if ([pin getDistance]) {
                
                [self.pinDistance setHidden:NO];
                [self.pinDistance setText:[pin getDistance]];
                [self.distancePin setHidden:NO];
            }
            else {
                
                [self.pinDistance setHidden:YES];
                [self.distancePin setHidden:YES];
                
                self.labelViewHeightConstraint.constant = 0;
            }
        }
        else if ([type isEqualToString:@"Watch Party"]){
            
            commonString = [NSString stringWithFormat:@"%@ Watch Party",title];
            [self.pinLabel setText:commonString];
            [self.icon setImage:[UIImage imageNamed:@"Watch Party"]];
            
            if ([pin getDistance]) {
                
                [self.pinDistance setHidden:NO];
                [self.pinDistance setText:[pin getDistance]];
                [self.distancePin setHidden:NO];
            }
            else {
                
                [self.pinDistance setHidden:YES];
                [self.distancePin setHidden:YES];
                
                self.labelViewHeightConstraint.constant = -8;
            }
        }
        else {
            
            commonString = [NSString stringWithFormat:@"%@",title];
            [self.pinLabel setText:commonString];
            
         //   if ([type isEqualToString:@"City"])
          //      [self.icon setImage:[UIImage imageNamed:@"city"]];
            
            [self.pinDistance setHidden:YES];
            [self.distancePin setHidden:YES];
            
            self.labelViewHeightConstraint.constant = -8;
        }
    
    self.pinLabel.textColor = [UIColor lightGrayColor];
   /* }
    else if ([pin isKindOfClass:[Stadium class]]) {
        _pin = pin;
        
        NSString *title = [pin getSearchTitle];
        NSString *tags = [pin getSearchTags];
        NSString *type = [pin getPinType];
        
        NSString *commonString = [NSString stringWithFormat:@"%@ %@",title,tags];
        
        if (![type isEqualToString:@"Beer"]) {
            
            NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor]};
            NSDictionary *startAttrs = @{ NSForegroundColorAttributeName : [UIColor grayColor]};
            
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:commonString attributes:attrs];
            NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
            
            [mutableString setAttributes:startAttrs range:NSMakeRange(0, title.length)];
            
            [self.pinLabel setAttributedText:mutableString];
        }
        else {
            
            commonString = [NSString stringWithFormat:@"%@",title];
            [self.pinLabel setText:commonString];
        }
    }
    else
        NSLog(@"This is not Pin");*/
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
