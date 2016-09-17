//
//  GridMenuViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "GridMenuViewController.h"

@interface GridMenuViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@end

@implementation GridMenuViewController
@synthesize scrollview;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [scrollview setContentSize:CGSizeMake(1500, 1500)];
    [scrollview setScrollEnabled:YES];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:tapGR];
    [self.view setUserInteractionEnabled:YES];    
}

- (IBAction)menuButtonTaped:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gridMenu:didTapOnButton:)]) {
        [self.delegate gridMenu:self didTapOnButton:sender];
    }
}

- (IBAction)uniqueButtonTaped:(UIButton *)sender
{
    NSLog(@"Button Tapped");
    if (self.delegate && [self.delegate respondsToSelector:@selector(gridMenu:didTapOnUniqueButton:withID:)]) {
        [self.delegate gridMenu:self didTapOnUniqueButton:sender withID:[self uniqueIDForButtonTag:sender.tag]];
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)tapGR
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gridMenuDidTapBackground:)]) {
        [self.delegate gridMenuDidTapBackground:self];
    }
}

#pragma mark - Private

- (NSString *)uniqueIDForButtonTag:(NSInteger)tag
{
    switch (tag) {
        case 100: return kMyProfile;
        case 200: return kMeetMe;
        case 300: return kLeaderboard;
        case 400: return kFriendList;
        case 500: return kMyGroups;
    }
    return nil;
}

@end
