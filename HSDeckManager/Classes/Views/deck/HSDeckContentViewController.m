//
//  HSDeckContentViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSDeckContentViewController.h"

#import "HSCardCell.h"
#import "HSCard.h"
#import "HSDataCenter.h"
#import "HSDeck.h"

@interface HSDeckContentViewController ()
@property (nonatomic, weak) IBOutlet UITableView    *cardTableView;
@property (nonatomic, weak) IBOutlet HSCardCell     *cardCell;

@property (nonatomic, strong) NSFetchedResultsController *cardFetchedController;
@end

@implementation HSDeckContentViewController

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
- (NSFetchedResultsController*)cardFetchedController
{
	if (!_cardFetchedController)
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([HSCard class])
											inManagedObjectContext:mainDataCenter.managedObjectContext]];
		
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentDeck = %@", self.deck]];
        
        NSSortDescriptor *manaSort = [[NSSortDescriptor alloc] initWithKey:@"cardInfo.manaCost" ascending:YES];
        NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"cardInfo.name" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:manaSort, nameSort, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		_cardFetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                     managedObjectContext:mainDataCenter.managedObjectContext
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
		
		NSError *error = nil;
		if (![_cardFetchedController performFetch:&error])
		{
			NSLog(@"Error fetching card list: %@", [error localizedDescription]);
		}
		_cardFetchedController.delegate = self;
	}
	return _cardFetchedController;
}

/* Callback method when changes are made to the data */
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	[self.cardTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.cardTableView endUpdates];
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
			[self.cardTableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.cardTableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self.cardTableView reloadRowsAtIndexPaths:@[indexPath]
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
    id  sectionInfo = [[self.cardFetchedController sections] objectAtIndex:section];
    if ([sectionInfo respondsToSelector:@selector(numberOfObjects)])
        return [sectionInfo numberOfObjects];
    return 0;
}

/* Load and initialize the cell representing the artists from its nib file.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HSCardCellID = @"HSCardCellID";
    HSCardCell *cell = (HSCardCell*)[tableView dequeueReusableCellWithIdentifier:HSCardCellID];
    
    if (nil == cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"HSCardCell" owner:self options:nil];
        cell = self.cardCell;
        self.cardCell = nil;
    }
    
    HSCard *card = [self.cardFetchedController objectAtIndexPath:indexPath];
    [cell updateUIWithCard:card];
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
        HSCard *card = [self.cardFetchedController objectAtIndexPath:indexPath];
        [mainDataCenter.managedObjectContext deleteObject:card];
		[mainDataCenter saveContext];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

@end
