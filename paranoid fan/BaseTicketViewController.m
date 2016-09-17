//
//  BaseTicketViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "BaseTicketViewController.h"
#import "Constants.h"

@interface BaseTicketViewController ()

@end

@implementation BaseTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideController:)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)hideController:(UITapGestureRecognizer *)sender
{
    if ([self isShouldHideOnTap]) {
        [self hideSelf];
    }
}

- (void)hideSelf
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideTicketController object:self];
}

- (BOOL)isShouldHideOnTap
{
    return YES;
}

@end
