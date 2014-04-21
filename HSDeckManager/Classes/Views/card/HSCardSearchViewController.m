//
//  HSCardSearchViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 19/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSCardSearchViewController.h"
#import "HSCardSelectionViewController.h"

// View
#import "iCarousel.h"
#import "HSCardViewController.h"

// Data
#import "HSDataCenter.h"
#import "HSCardInfo.h"
#import "HSDeck.h"
#import "HSCard.h"

@interface HSCardSearchViewController ()
@property (nonatomic, weak) IBOutlet iCarousel      *cardCarousel;
@property (nonatomic, weak) IBOutlet UISearchBar    *searchBar;
@property (nonatomic, strong) NSArray *matchedResults;
@end

@implementation HSCardSearchViewController

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
    self.cardCarousel.type = iCarouselTypeRotary;
    [self reloadSearchData];
    [self.searchBar becomeFirstResponder];
    
    if (self.card.cardInfo.name.length > 0) {
        // Get card from name
        self.searchBar.text = self.card.cardInfo.fullname;
        /*
         int index = [self.matchedResults indexOfObject:self.card];
        // Scroll to card
        if (index > 0)
            index = index - 1;
        else
            index = self.matchedResults.count;
        
        [self.cardCarousel scrollToItemAtIndex:index animated:YES];
         */
        [self reloadSearchData];
    }
}

- (void)reloadSearchData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([HSCardInfo class]) inManagedObjectContext:mainDataCenter.managedObjectContext]];
    // Delete space from text
    NSString *key = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (0 < self.searchBar.text.length)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", key]];

    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSort]];
    
    self.matchedResults = [mainDataCenter.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    [self.cardCarousel reloadData];
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

- (IBAction)doneButtonDidClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - iCarousel methods
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.matchedResults.count;
}

- (UIView*)carousel:(iCarousel*)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView*)reuseView
{
    HSCardInfo *cardInfo = self.matchedResults[index];
    HSCardViewController *cardVC = [[HSCardViewController alloc] initWithNibName:nil bundle:nil];
    cardVC.cardInfo = cardInfo;
    return cardVC.view;
}

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return 150;
}

/* User tap to a card */
- (void)carousel:(iCarousel*)carousel didSelectItemAtIndex:(NSInteger)index
{
    // If it is the centered page, we select the card
    if (carousel.currentItemIndex == index)
    {
        HSCardInfo *selectedCardInfo = self.matchedResults[carousel.currentItemIndex];
        
        HSCard *newCard = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HSCard class]) inManagedObjectContext:mainDataCenter.managedObjectContext];
        newCard.cardInfo = selectedCardInfo;
        [self.deck addCardsObject:newCard];
        [self doneButtonDidClick:nil];
        
        // Call fatherview
        HSCardSelectionViewController *fatherVc = (HSCardSelectionViewController *)[(UITabBarController *)[(UINavigationController *)self.presentingViewController topViewController] selectedViewController];
        if (fatherVc && [(HSCardSelectionViewController *)fatherVc respondsToSelector:@selector(foundCard:)]) {
            [(HSCardSelectionViewController *)fatherVc foundCard:newCard];
        }
    }
}

/* The carousel type is Rotary, so its visual effect is not good if there are only
 * 2 items (the 2nd view is hidden behind the 1st view). In this case we add 2 more
 * placeholder items to make a better rotation effect. */
- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    if (2 == self.matchedResults.count)
        return 2;
    else
        return 0;
}

/* Placeholder view is simply an invisible placeholder empty card (to have the same dimension) */
- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    HSCardViewController *cardVC = [[HSCardViewController alloc] initWithNibName:nil bundle:nil];
    cardVC.view.alpha = 0;
    return cardVC.view;
}

/* The carousel is wrapped, unless there are only 2 items or less */
- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
            if (self.matchedResults.count < 3)
                return NO;
            else
                return YES;
        default:
            return value;
    }
}

#pragma mark - Private method
- (NSUInteger) indexOfCard:(NSString *)cardName
{
    /*
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([HSCardInfo class]) inManagedObjectContext:mainDataCenter.managedObjectContext]];
    // Delete space from text
    NSString *key = [self.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (0 < self.searchBar.text.length)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", key]];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[nameSort]];
    
    self.matchedResults = [mainDataCenter.managedObjectContext executeFetchRequest:fetchRequest error:nil];
     */
    return 1;
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    [self reloadSearchData];
}

@end
