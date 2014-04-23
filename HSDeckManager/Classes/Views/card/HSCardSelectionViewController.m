//
//  HSCardSelectionViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSCardSelectionViewController.h"
#import "HSCardViewController.h"

// View
#import "HSCardSearchViewController.h"

// Data
#import "HSDataCenter.h"
#import "HSDeck.h"
#import "HSCardInfo.h"
#import "HSCard.h"

// Category
#import "UIImage+HS.h"

@interface HSCardSelectionViewController ()

@property (nonatomic) int tagButton;
@property (nonatomic, strong) NSMutableDictionary *listThreeCards;

@end

@implementation HSCardSelectionViewController

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
    if (self.listThreeCards == nil) {
        self.listThreeCards = [NSMutableDictionary dictionary];
    }
    [self resetViewForCard];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    HSCardSearchViewController *searchVC = segue.destinationViewController;
    searchVC.deck = self.deck;
    HSCard *card = (HSCard *)[self.listThreeCards objectForKey:@(self.tagButton)];
    if (card !=nil && card.cardInfo.name.length > 0) {
        [searchVC setCard:card];
    }
}


#pragma mark - IBActon
- (IBAction)cardDidClick:(UIButton*)cardButton
{
    // Card choosen => New 3 cards
    self.tagButton = [self.selectionCardButtons indexOfObject:cardButton];
}

- (IBAction)cardDidChoosen:(id)sender
{
    // Get card from key
    NSInteger index = [self.addDeckCardButton indexOfObject:sender];
    HSCard *card = [self.listThreeCards objectForKey:@(index)];
    [self.deck addCardsObject:card];
    // Reset all info
    [self.listThreeCards removeAllObjects];
    [self resetViewForCard];
}


#pragma mark - Private methods
- (void)foundCard:(HSCard *)aCard
{
    if (aCard) {
        [self.listThreeCards setObject:aCard forKey:@(self.tagButton)];
        // Update rate for card and show it
        float rate = [mainDataCenter rateForCardInfo:aCard.cardInfo withClass:self.deck.hero];
        aCard.rate = @(rate);
        // Rate
        UILabel *aLabel = [self.infoCardLabels objectAtIndex:self.tagButton];
        NSString *valueStr = [mainDataCenter rateStringFromValue:[aCard.rate floatValue]];
        NSString *text = [NSString stringWithFormat:@"Value: %@ \n\n %@",aCard.rate,valueStr];
        aLabel.text = text;
    }
    // Update image
    HSCardViewController *hsVC = [[HSCardViewController alloc] init];
    hsVC.cardInfo = aCard.cardInfo;
    UIImage *bg = [UIImage imageFromView:hsVC.view];
    UIButton *button = [self.selectionCardButtons objectAtIndex:self.tagButton];
    [button setBackgroundImage:bg forState:UIControlStateNormal];
    [button setTitle:nil forState:UIControlStateNormal];
    // Show button
    UIButton *addButton = [self.addDeckCardButton objectAtIndex:self.tagButton];
    addButton.hidden = NO;
}

- (void)resetViewForCard
{
    // Button
    for (UIButton *button in self.selectionCardButtons) {
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Selection" forState:UIControlStateNormal];
    }
    // Label
    for (UILabel *label in self.infoCardLabels) {
        label.text = nil;
    }
    // Button add to deck
    for (UIButton *button in self.addDeckCardButton) {
        button.hidden = YES;
    }
}


@end
