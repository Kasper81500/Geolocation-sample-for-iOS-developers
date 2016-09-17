//
//  TagsViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/16/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "TagsViewController.h"
#import <THContactPickerView.h>
#import "TeamsDropTableViewController.h"
#import "Engine.h"
#import "Constants.h"

#define kDropDownSegue @"TeamsDropDown"

@interface TagsViewController ()<TeamDropDownDelegate, THContactPickerDelegate>

@property (nonatomic, weak) IBOutlet THContactPickerView *contactPickerView;
@property (nonatomic, weak) TeamsDropTableViewController *teamDropDownController;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagsHeightConstraints;
@property (nonatomic, strong) NSMutableArray *selectedTags;

@end

@implementation TagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.contactPickerView setPlaceholderLabelText:@"Teams (optional)"];
    
    THContactViewStyle *normalStyle = [[THContactViewStyle alloc] initWithTextColor:[UIColor darkGrayColor]
                                                                    backgroundColor:rgbColor(255.0, 255.0, 255.0)
                                                                 cornerRadiusFactor:0.0];
    
    THContactViewStyle *selectedStyle = [[THContactViewStyle alloc] initWithTextColor:rgbColor(27, 153, 214)
                                                                    backgroundColor:[UIColor redColor]
                                                                 cornerRadiusFactor:0.0];
    
    [self.contactPickerView setContactViewStyle:normalStyle selectedStyle:selectedStyle];
    self.contactPickerView.delegate = self;
    self.contactPickerView.backgroundColor = [UIColor whiteColor];
    [self.contactPickerView setFont:[UIFont fontWithName:@"Roboto-Regular" size:14.0]];
    

    [self.contactPickerView setPlaceholderLabelTextColor:self.placeHolderColor ? self.placeHolderColor : rgbaColor(0, 0, 25.5, 0.22)];

    _teamDropDownController.tableView.hidden = YES;
   
    
    self.selectedTags = [NSMutableArray array];
        
    [self loadAllTeams];
}

#pragma mark - Loading

- (void)loadAllTeams
{
    [[[Engine sharedEngine] dataManager] getAllTeamsWithCallBack:^(BOOL success, id result, NSString *errorInfo) {
        if (success) {
            NSLog(@"ALL Tag teams %@",result);
            
            NSArray *teams = (NSArray *)result;
            NSArray *teamSport = [teams valueForKey:@"team"];
            
            self.teamDropDownController.items = [NSMutableArray arrayWithArray:teamSport];
            
            NSLog(@"Picker View Rect: %@",NSStringFromCGRect(_contactPickerView.frame));
            
            if ([self.teamDropDownController.tableView isHidden])
                NSLog(@"Table is Hidden");
            else {
                NSLog(@"Table Rect %@", NSStringFromCGRect(self.teamDropDownController.tableView.frame));
            }
        }
    }];
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Calling Segue: %@", segue.identifier);
    if ([segue.identifier isEqualToString:kDropDownSegue]) {
        NSLog(@"Calling Segue: %@", kDropDownSegue);
        self.teamDropDownController = segue.destinationViewController;
        self.teamDropDownController.teamDelegate = self;
    }
}

#pragma mark - THContactPickerDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText
{
    if (textViewText.length > 0)
        _teamDropDownController.tableView.hidden = NO;
    else
        _teamDropDownController.tableView.hidden = YES;
    [self.teamDropDownController setSearchString:textViewText];
}

- (void)contactPickerDidRemoveContact:(id)contact
{
    [self.selectedTags removeObject:contact];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView
{
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),NSStringFromCGRect(contactPickerView.frame));
    
    if (self.tagsHeightConstraints.constant != CGRectGetHeight(contactPickerView.bounds)) {
        self.tagsHeightConstraints.constant = CGRectGetHeight(contactPickerView.bounds);
        [self.view layoutIfNeeded];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsViewController:didResize:)]) {
        [self.delegate tagsViewController:self didResize:contactPickerView.bounds.size];
    }
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.teamDropDownController setSearchString:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsViewController:didEndSelectingWithSize:)]) {
        [self.delegate tagsViewController:self didEndSelectingWithSize:self.contactPickerView.bounds.size];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagsViewController:didSelectedTags:)]) {
        [self.delegate tagsViewController:self didSelectedTags:self.selectedTags];
    }
    
    return YES;
}

#pragma mark - TeamDropDownDelegate

- (void)teamTableView:(TeamsDropTableViewController *)teamTableView didSelectTeam:(NSString *)team
{
    if (self.selectedTags.count >= 2) {
        [[[UIAlertView alloc] initWithTitle:nil
                                   message:@"You can’t add more then 2 teams"
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    } else {
        [self.contactPickerView addContact:team withName:team];
        [self.selectedTags addObject:team];
    }
}


@end
