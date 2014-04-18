//
//  HSDeckListViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSDeckListViewController.h"

// Views
#import "HSDeckCell.h"

// Data
#import "HSDataCenter.h"
#import "HSDeck.h"

@interface HSDeckListViewController ()
@property (nonatomic, weak) IBOutlet UITableView    *deckTableView;
@property (nonatomic, weak) IBOutlet HSDeckCell     *deckCell;

@property (nonatomic, strong) NSFetchedResultsController *deckFetchedController;
@end

@implementation HSDeckListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Core Data and UI Binding
- (NSFetchedResultsController*)deckFetchedController
{
	if (!_deckFetchedController)
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([HSDeck class])
											inManagedObjectContext:mainDataCenter.managedObjectContext]];
		
        NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastDate" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:dateSort, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		_deckFetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:mainDataCenter.managedObjectContext
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
		
		NSError *error = nil;
		if (![_deckFetchedController performFetch:&error])
		{
			NSLog(@"Error fetching deck list: %@", [error localizedDescription]);
		}
		_deckFetchedController.delegate = self;
	}
	return _deckFetchedController;
}

/* Callback method when changes are made to the data */
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	[self.deckTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.deckTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath*)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath*)newIndexPath
{
	switch (type)
	{
		case NSFetchedResultsChangeInsert:
			[self.deckTableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.deckTableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self.deckTableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
			break;
		default:
			break;
	}
}

#pragma mark Table Views Delegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.deckFetchedController.fetchedObjects.count;
}

/* Load and initialize the cell representing the artists from its nib file.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HSDeckCellID = @"HSDeckCellID";
    HSDeckCell *cell = (HSDeckCell*)[tableView dequeueReusableCellWithIdentifier:HSDeckCellID];
    
    if (nil == cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"HSDeckCell" owner:self options:nil];
        cell = self.deckCell;
        self.deckCell = nil;
    }
    
    HSDeck *deck = [self.deckFetchedController objectAtIndexPath:indexPath];
    [cell updateUIWithDeck:deck];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
	{
		// Delete the managed object.
        HSDeck *deck = [self.deckFetchedController objectAtIndexPath:indexPath];
        [mainDataCenter.managedObjectContext deleteObject:deck];
		[mainDataCenter saveContext];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

@end