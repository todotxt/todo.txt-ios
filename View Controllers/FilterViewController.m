//
//  FilterViewController.m
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/14/13.
//
//

#import "FilterViewController.h"

@interface FilterViewController ()

- (IBAction)selectedSegment:(UISegmentedControl *)sender;

@property (assign, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (strong, nonatomic) NSArray *contexts;
@property (strong, nonatomic) NSArray *projects;

@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Filter";
    self.navigationItem.titleView = self.typeSegmentedControl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Build filters...
    
    [self.filterTarget filterForContexts:self.contexts projects:self.projects];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Build filters...
    
    [self.filterTarget filterForContexts:self.contexts projects:self.projects];
}

#pragma mark - IBActions

- (void)selectedSegment:(UISegmentedControl *)sender
{
    
}

@end
