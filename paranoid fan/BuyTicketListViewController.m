//
//  BuyTicketListViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/7/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "BuyTicketListViewController.h"
#import "Engine.h"
#import "Ticket.h"
#import "User.h"
#import "TicketTableViewCell.h"
#import "BuyTicketDetailViewController.h"

#define kSegueBuyTicket @"buyTicket"

@interface BuyTicketListViewController ()<UITableViewDataSource, UITableViewDelegate, TicketTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) Ticket *selectedTicket;


@end

@implementation BuyTicketListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadAllTickets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableViewDelegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tickets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"ticketCell";
    Ticket *ticket = self.tickets[indexPath.row];
    
    if ([ticket.type isEqualToString:@"TICKETMASTER"])
        cellID = @"ticketMasterCell";
    
    TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.ticket = ticket;
    cell.delegate = self;
    
    return cell;
    
}

#pragma mark - TicketCellDelegate

- (void)ticketCell:(TicketTableViewCell *)cell willBuyTicket:(Ticket *)ticket
{
    self.selectedTicket = ticket;
    
    if ([ticket.type isEqualToString:@"TICKETMASTER"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: ticket.eventURL]];
    else
        [self performSegueWithIdentifier:kSegueBuyTicket sender:self];
}

#pragma mark - Ticket manager

- (void)loadAllTickets
{
    [[[Engine sharedEngine] dataManager] getAllTicketsWithCallBack:^(BOOL success, id result, NSString *errorInfo)
    {
        if (success) {
            self.tickets = (NSArray *)result;
            [self.tableView reloadData];
            
            BOOL isHideFooter = self.tickets.count != 0;            
            self.tableView.tableFooterView.hidden = isHideFooter;
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kSegueBuyTicket]) {
        BuyTicketDetailViewController *nextVC = (BuyTicketDetailViewController *)segue.destinationViewController;
        nextVC.ticket = self.selectedTicket;
    }
}



@end
