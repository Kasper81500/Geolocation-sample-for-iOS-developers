//
//  DropTableViewController.m
//  paranoid fan
//
//  Created by Stanislav Dymedyuk on 9/6/15.
//  Copyright (c) 2015 shilin. All rights reserved.
//

#import "DropTableViewController.h"

@interface DropTableViewController ()

@end

@implementation DropTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)setItems:(NSMutableArray *)items
{
    _items = items;
    _filteredItems = [self fillteredItemsWithString:self.searchString];
 //   NSLog(@"<<%lu", (unsigned long)[_filteredItems count]);
    [self.tableView reloadData];
}

- (void)setSearchString:(NSString *)searchString
{
    
     NSLog(@"This is also called");
    _searchString = searchString;
    _filteredItems = [self fillteredItemsWithString:self.searchString];
//    NSLog(@"<>%lu", (unsigned long)[_filteredItems count]);
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)removeItem:(id)item
{
    [self.items removeObject:item];
    _filteredItems = [self fillteredItemsWithString:self.searchString];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self customNumberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self customCellForIndexPath:indexPath];
}


#pragma mark - CustomDropDownCell

- (UITableViewCell *)customCellForIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"This custom cell called");
    return nil; // implement logic in deliver methods
}

- (NSArray *)fillteredItemsWithString:(NSString *)filterString
{
    return nil; // implement logic in deliver methods
}

- (NSInteger) customNumberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"This custom NumOfRows called");
    return 0; // implement logic in deliver methods
}

- (NSArray *)fillteredItemsWithString:(NSString *)filterString withArray:(NSMutableArray *)sourceArray {
    
    return nil;
}

@end
