//
//  FavoriteTableViewCell.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/25/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "FavoriteTableViewCell.h"
#import "Engine.h"
#import "NSDate+TimeAgo.h"

@interface FavoriteTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *rating1;
@property (nonatomic, weak) IBOutlet UIImageView *rating2;
@property (nonatomic, weak) IBOutlet UIImageView *rating3;
@property (nonatomic, weak) IBOutlet UIImageView *rating4;
@property (nonatomic, weak) IBOutlet UIImageView *rating5;
@property (nonatomic, weak) IBOutlet UILabel *dateAdded;
@property (nonatomic, weak) IBOutlet UILabel *distance;
@property (nonatomic, weak) IBOutlet UILabel *stadium;
@property (nonatomic, weak) IBOutlet UIButton *directionBtn;
@property (nonatomic, weak) IBOutlet UIButton *shareBtn;
@property (nonatomic, weak) IBOutlet UIButton *likeBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *iconHeightConstant;

@end

@implementation FavoriteTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setPin:(Pin *)pin
{
    _pin = pin;
    
    NSString *mapPinType = [pin mapPinType];
    NSString *mapPinTags = [pin getSearchTags];
    NSString *pinImage = nil;
    
    if ([mapPinType isEqualToString:@"Beer"]) {
        
        /*
        if ([mapPinTags containsString:@"American Outlaws"])
            pinImage = [mapPinType stringByAppendingString:@"_AO"];
        else if ([mapPinTags containsString:@"Bears"])
            pinImage = [mapPinType stringByAppendingString:@"_Bears"];
        else if ([mapPinTags containsString:@"Bills"])
            pinImage = [mapPinType stringByAppendingString:@"_Bills"];
        else if ([mapPinTags containsString:@"Colts"])
            pinImage = [mapPinType stringByAppendingString:@"_Colts"];
        else if ([mapPinTags containsString:@"Jets"])
            pinImage = [mapPinType stringByAppendingString:@"_Jets"];
        else if ([mapPinTags containsString:@"Lions"])
            pinImage = [mapPinType stringByAppendingString:@"_Lions"];
        else if ([mapPinTags containsString:@"49ers"])
            pinImage = [mapPinType stringByAppendingString:@"_49ers"];
        else if ([mapPinTags containsString:@"Bengals"])
            pinImage = [mapPinType stringByAppendingString:@"_Bengals"];
        else if ([mapPinTags containsString:@"Bronocos"])
            pinImage = [mapPinType stringByAppendingString:@"_Bronocos"];
        else if ([mapPinTags containsString:@"Browns"])
            pinImage = [mapPinType stringByAppendingString:@"_Browns"];
        else if ([mapPinTags containsString:@"Buccaneers"])
            pinImage = [mapPinType stringByAppendingString:@"_Buccaneers"];
        else if ([mapPinTags containsString:@"Cardinals"])
            pinImage = [mapPinType stringByAppendingString:@"_Cardinals"];
        else if ([mapPinTags containsString:@"Chargers"])
            pinImage = [mapPinType stringByAppendingString:@"_Chargers"];
        else if ([mapPinTags containsString:@"Chiefs"])
            pinImage = [mapPinType stringByAppendingString:@"_Chiefs"];
        else if ([mapPinTags containsString:@"Cowboys"])
            pinImage = [mapPinType stringByAppendingString:@"_Cowboys"];
        else if ([mapPinTags containsString:@"Dolphins"])
            pinImage = [mapPinType stringByAppendingString:@"_Dolphins"];
        else if ([mapPinTags containsString:@"Eagles"])
            pinImage = [mapPinType stringByAppendingString:@"_Eagles"];
        else if ([mapPinTags containsString:@"Falcons"])
            pinImage = [mapPinType stringByAppendingString:@"_Falcons"];
        else if ([mapPinTags containsString:@"Giants"])
            pinImage = [mapPinType stringByAppendingString:@"_Giants"];
        else if ([mapPinTags containsString:@"Jaguars"])
            pinImage = [mapPinType stringByAppendingString:@"_Jaguars"];
        else if ([mapPinTags containsString:@"Packers"])
            pinImage = [mapPinType stringByAppendingString:@"_Packers"];
        else if ([mapPinTags containsString:@"Panthers"])
            pinImage = [mapPinType stringByAppendingString:@"_Panthers"];
        else if ([mapPinTags containsString:@"Patriots"])
            pinImage = [mapPinType stringByAppendingString:@"_Patriots"];
        else if ([mapPinTags containsString:@"Raiders"])
            pinImage = [mapPinType stringByAppendingString:@"_Raiders"];
        else if ([mapPinTags containsString:@"Rams"])
            pinImage = [mapPinType stringByAppendingString:@"_Rams"];
        else if ([mapPinTags containsString:@"Ravens"])
            pinImage = [mapPinType stringByAppendingString:@"_Ravens"];
        else if ([mapPinTags containsString:@"Redskin"])
            pinImage = [mapPinType stringByAppendingString:@"_Redskin"];
        else if ([mapPinTags containsString:@"Saints"])
            pinImage = [mapPinType stringByAppendingString:@"_Saints"];
        else if ([mapPinTags containsString:@"Seahawks"])
            pinImage = [mapPinType stringByAppendingString:@"_Seahawks"];
        else if ([mapPinTags containsString:@"Steelers"])
            pinImage = [mapPinType stringByAppendingString:@"_Steelers"];
        else if ([mapPinTags containsString:@"Texans"])
            pinImage = [mapPinType stringByAppendingString:@"_Texans"];
        else if ([mapPinTags containsString:@"Titans"])
            pinImage = [mapPinType stringByAppendingString:@"_Titans"];
        else if ([mapPinTags containsString:@"Vikings"])
            pinImage = [mapPinType stringByAppendingString:@"_Vikings"];
        else if ([mapPinTags containsString:@"Arsenal"])
            pinImage = [mapPinType stringByAppendingString:@"_Arsenal"];
        else if ([mapPinTags containsString:@"Barcelona"])
            pinImage = [mapPinType stringByAppendingString:@"_Barcelona"];
        else if ([mapPinTags containsString:@"Chelsea"])
            pinImage = [mapPinType stringByAppendingString:@"_Chelsea"];
        else if ([mapPinTags containsString:@"Liverpool"])
            pinImage = [mapPinType stringByAppendingString:@"_Liverpool"];
        else if ([mapPinTags containsString:@"Manchester United"])
            pinImage = [mapPinType stringByAppendingString:@"_Manchester United"];
        else if ([mapPinTags containsString:@"Florida"])
            pinImage = [mapPinType stringByAppendingString:@"_Florida"];
        else if ([mapPinTags containsString:@"Ohio"])
            pinImage = [mapPinType stringByAppendingString:@"_Ohio"];
        else if ([mapPinTags containsString:@"Iowa"])
            pinImage = [mapPinType stringByAppendingString:@"_Iowa"];
        else if ([mapPinTags containsString:@"LSU"])
            pinImage = [mapPinType stringByAppendingString:@"_LSU"];
        else if ([mapPinTags containsString:@"Texas"])
            pinImage = [mapPinType stringByAppendingString:@"_Texas"];
        else if ([mapPinTags containsString:@"USC"])
            pinImage = [mapPinType stringByAppendingString:@"_USC"];
        else if ([mapPinTags containsString:@"Utah"])
            pinImage = [mapPinType stringByAppendingString:@"_Utah"];
        else if ([mapPinTags containsString:@"Air Force"])
            pinImage = [mapPinType stringByAppendingString:@"_Air Force"];
        else if ([mapPinTags containsString:@"Alabama"])
            pinImage = [mapPinType stringByAppendingString:@"_Alabama"];
        else if ([mapPinTags containsString:@"Arizona"])
            pinImage = [mapPinType stringByAppendingString:@"_Arizona"];
        else if ([mapPinTags containsString:@"Auburn"])
            pinImage = [mapPinType stringByAppendingString:@"_Auburn"];
        else if ([mapPinTags containsString:@"Georgia Tech"])
            pinImage = [mapPinType stringByAppendingString:@"_Georgia Tech"];
        else if ([mapPinTags containsString:@"Georgia"])
            pinImage = [mapPinType stringByAppendingString:@"_Georgia"];
        else if ([mapPinTags containsString:@"Kentucky"])
            pinImage = [mapPinType stringByAppendingString:@"_Kentucky"];
        else if ([mapPinTags containsString:@"Louisville"])
            pinImage = [mapPinType stringByAppendingString:@"_Louisville"];
        else if ([mapPinTags containsString:@"Michigan State"])
            pinImage = [mapPinType stringByAppendingString:@"_Michigan State"];
        else if ([mapPinTags containsString:@"Michigan"])
            pinImage = [mapPinType stringByAppendingString:@"_Michigan"];
        else if ([mapPinTags containsString:@"Missouri"])
            pinImage = [mapPinType stringByAppendingString:@"_Missouri"];
        else if ([mapPinTags containsString:@"Nebraska"])
            pinImage = [mapPinType stringByAppendingString:@"_Nebraska"];
        else if ([mapPinTags containsString:@"North Carolina"])
            pinImage = [mapPinType stringByAppendingString:@"_North Carolina"];
        else if ([mapPinTags containsString:@"Notre Dame"])
            pinImage = [mapPinType stringByAppendingString:@"_Notre Dame"];
        else if ([mapPinTags containsString:@"Oklahoma"])
            pinImage = [mapPinType stringByAppendingString:@"_Oklahoma"];
        else if ([mapPinTags containsString:@"Oregon"])
            pinImage = [mapPinType stringByAppendingString:@"_Oregon"];
        else if ([mapPinTags containsString:@"Pittsburgh"])
            pinImage = [mapPinType stringByAppendingString:@"_Pittsburgh"];
        else if ([mapPinTags containsString:@"Purdue"])
            pinImage = [mapPinType stringByAppendingString:@"_Purdue"];
        else if ([mapPinTags containsString:@"Syracuse"])
            pinImage = [mapPinType stringByAppendingString:@"_Syracuse"];
        else if ([mapPinTags containsString:@"Virginia Tech"])
            pinImage = [mapPinType stringByAppendingString:@"_Virginia Tech"];
        else
         */
        
        pinImage = [mapPinType stringByAppendingFormat:@"_%@", mapPinTags];
        
        if ([UIImage imageNamed:pinImage] == nil)        
            pinImage = [NSString stringWithFormat:@"menu_v2_%@",mapPinType];
    }
    else
        pinImage = [NSString stringWithFormat:@"menu_v2_%@",mapPinType];
    
    UIImage *pinImageMarker = [UIImage imageNamed:pinImage];
    
    
    self.icon.image = pinImageMarker;
    float ratio = pinImageMarker.size.height/pinImageMarker.size.width;
    float newHeight = self.icon.frame.size.height*ratio;
    self.iconHeightConstant.constant = ceilf(newHeight);
    
    self.titleLabel.text = pin.mapPinTitle;
    
    if (self.pin.mapAddress != nil && self.pin.mapAddress != NULL && ![self.pin.mapAddress isEqualToString:@"(null)"] && ![self.pin.mapAddress isEqualToString:@""]) {
        self.stadium.text = self.pin.mapAddress;
        NSLog(@"Existing Address: %@", self.pin.mapAddress);
    }
    else {
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[self.pin getLocation] completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(placemarks && placemarks.count > 0)
             {
                 CLPlacemark *placemark= [placemarks objectAtIndex:0];
                 
                 if ([placemark subThoroughfare] == nil || [placemark thoroughfare] == nil || [placemark subThoroughfare] == NULL || [placemark thoroughfare] == NULL)
                     self.stadium.text = @"Exact address unavailable";
                 else
                     self.stadium.text = [NSString stringWithFormat:@"%@ %@, %@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
                 self.pin.mapAddress = self.stadium.text;
                 NSLog(@"Current Address: %@", self.stadium.text);
             }
             
         }];
    }

    NSComparisonResult result = [[NSDate date] compare:pin.dateCreated];
    
    if (result == NSOrderedAscending) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM d, hh:mm a"];
        NSString *dateString = [dateFormatter stringFromDate:pin.dateCreated];
        self.dateAdded.text = [NSString stringWithFormat:@"%@", dateString];
    }
    else
        self.dateAdded.text = [pin.dateCreated timeAgo];
    
    self.distance.text = [pin.distance stringByReplacingOccurrencesOfString:@" miles away" withString:@" mi"];
    [self setupRating:pin];

    if (pin.isFavorite)
        [self.likeBtn setSelected:YES];
    else
        [self.likeBtn setSelected:NO];
}

- (void) setupRating:(Pin *)pin {
    
    if (pin.rating == 1) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (pin.rating == 2) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (pin.rating == 3) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_empty"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (pin.rating == 4) {
        
        [self.rating1 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating2 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating3 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating4 setImage:[UIImage imageNamed:@"star_fill"]];
        [self.rating5 setImage:[UIImage imageNamed:@"star_empty"]];
    }
    else if (pin.rating == 5) {
        
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


@end
