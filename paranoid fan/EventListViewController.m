//
//  EventListViewController.m
//  paranoid fan
//
//  Created by Adeel Asim on 3/27/16.
//  Copyright © 2016 shilin. All rights reserved.
//

#import "EventListViewController.h"
#import "FavoriteTableViewCell.h"
#import "Pin.h"
#import "Engine.h"
#import "User.h"
#import "Constants.h"
#import <Google/Analytics.h>
#import "MeetMeListViewController.h"

@interface EventListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) NSMutableSet *allPins;
@property (strong, nonatomic) NSMutableArray *pins;
@property (strong, nonatomic) NSMutableArray *groups;


@end

@implementation EventListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblView.delaysContentTouches = NO;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    self.tblView.estimatedRowHeight = 135.0;
    self.tblView.hidden = YES;
    [[[Engine sharedEngine] dataManager] getCloseByEventsPins:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            
            self.pins = [result mutableCopy];
//            self.allPins = [NSMutableSet setWithSet:favPins];
//            self.pins = [[self.allPins allObjects] mutableCopy];
            self.tblView.hidden = NO;
            [self.tblView reloadData];
            
        }
    }];
    
    [[[Engine sharedEngine] dataManager] getMyGroupsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            
            self.groups = [result mutableCopy];
            
        }
    }];
}

- (IBAction) goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"favoriteCell";
    
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    Pin *pin = self.pins[indexPath.row];
    cell.pin = pin;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    Pin *showPin = self.pins[indexPath.row];
    
    NSDictionary* userInfo = @{@"pin": showPin};
    [[NSNotificationCenter defaultCenter]
                 postNotificationName:kNotificationShowPinPopup
                                                         object:self userInfo:userInfo];
    
    [self goBack];
}

- (IBAction)showDirection:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    CLLocation *userLocation = [[[[Engine sharedEngine] settingManager] user] getLocation];
    CLLocationCoordinate2D pinCoords = [self.pins[indexPath.row] getLocationCoordinate];
    
    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude, pinCoords.latitude, pinCoords.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString]];
}

- (IBAction)sharePin:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    Pin *pin = self.pins[indexPath.row];
    CLLocationCoordinate2D pinCoords = [pin getLocationCoordinate];
    
    NSString *shareString = [NSString stringWithFormat:@"http://paranoidfan.com/meetme.php?type=%@&latittude=%f&longitude=%f&pid=%ld", [[self.pins[indexPath.row] getPinType] stringByReplacingOccurrencesOfString:@" " withString:@"_"], pinCoords.latitude, pinCoords.longitude, pin.pinID];
    
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

- (IBAction)share:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    Pin *pin = self.pins[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MeetMeListViewController *meetMeListVC = [storyboard instantiateViewControllerWithIdentifier:@"meetmelist"];
    meetMeListVC.isShare = YES;
    meetMeListVC.groups = self.groups;
    meetMeListVC.pinID = pin.pinID;
    [self.navigationController pushViewController:meetMeListVC animated:NO];
}

- (IBAction)likeSpot:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tblView];
    NSIndexPath *indexPath = [self.tblView indexPathForRowAtPoint:buttonPosition];
    
    Pin *pin = self.pins[indexPath.row];
    
    UIButton* btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        
        [[[Engine sharedEngine] dataManager] addFavorite:pin.pinID withCallBack:^(BOOL success, id result, NSString *errorInfo) {

            if (success) {
                
                pin.isFavorite = TRUE;
                
            } else {
                
            }
        }];
    }
    else {
        
        [[[Engine sharedEngine] dataManager] removeFavorite:pin.pinID withCallBack:^(BOOL success, id result, NSString *errorInfo) {

            if (success) {
                
                pin.isFavorite = NO;
                
            } else {
                
            }
        }];
    }
}

@end
