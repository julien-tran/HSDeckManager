//
//  HSCardSelectionViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSCardSelectionViewController.h"

// View
#import "HSCardSearchViewController.h"

// Data
#import "HSDeck.h"
#import "HSCardInfo.h"
#import "HSCard.h"

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
    HSCard *card = (HSCard *)[self.listThreeCards objectForKey:@([(UIButton *)sender tag])];
    if (card !=nil && card.cardInfo.name.length > 0) {
        [searchVC setCard:card];
    }
}

- (IBAction)cardDidClick:(UIButton*)cardButton
{
    // Card choosen => New 3 cards
    self.tagButton = cardButton.tag;
}

- (void)foundCard:(HSCard *)aCard
{
    if (aCard) {
        // Check if card already added
        [self.listThreeCards setObject:aCard forKey:@(self.tagButton)];
        // TEST
        UILabel *aLabel = nil;
        switch (self.tagButton) {
            case 1:
                aLabel = self.cardOneLabel;
                break;
            case 2:
                aLabel = self.cardTwoLabel;
                break;
            case 3:
                aLabel = self.cardThreeLabel;
                break;
            default:
                break;
        }
        aLabel.text = aCard.cardInfo.fullname;
    }
}

@end
