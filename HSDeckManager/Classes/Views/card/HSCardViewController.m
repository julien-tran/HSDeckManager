//
//  HSCardViewController.m
//  HSDeckManager
//
//  Created by Julien Tran on 19/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSCardViewController.h"
#import "HSCardInfo.h"

#define LEGENDARY   @"legendary"
#define EPIC        @"epic"
#define COMMON      @"common"

@interface HSCardViewController ()

@property (nonatomic, weak) IBOutlet UIImageView    *cardFrame;
@property (nonatomic, weak) IBOutlet UIImageView    *minionImage;
@property (nonatomic, weak) IBOutlet UIImageView    *spellImage;
@property (nonatomic, weak) IBOutlet UIImageView    *weaponImage;
@property (nonatomic, weak) IBOutlet UIImageView    *legendaryFrame;
@property (nonatomic, weak) IBOutlet UILabel        *descriptionView;
@property (weak, nonatomic) IBOutlet UILabel        *manaLabel;
@property (weak, nonatomic) IBOutlet UILabel        *attackLabel;
@property (weak, nonatomic) IBOutlet UILabel        *healthLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *titleCardImageView;
@property (weak, nonatomic) IBOutlet UIImageView    *rarityImageView;
@property (weak, nonatomic) IBOutlet UIImageView *titleSpellImageView;
@property (weak, nonatomic) IBOutlet UIImageView *spellImageView;
@property (weak, nonatomic) IBOutlet UIImageView *spellRarityImage;
;

@end

@implementation HSCardViewController

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
    // Do any additional setup after loading the view from its nib.
    self.view.clipsToBounds = NO;
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    // Common
    self.attackLabel.hidden = (self.cardInfo.isSpell.boolValue);
    self.healthLabel.hidden = (self.cardInfo.isSpell.boolValue);
    NSString *title = [NSString stringWithFormat:@"Title_%@.png", self.cardInfo.name];
    self.titleCardImageView.image = [UIImage imageNamed:title];
    self.titleSpellImageView.image = nil;
    self.manaLabel.text = [NSString stringWithFormat:@"%d", self.cardInfo.manaCost.intValue];
    self.descriptionView.text = self.cardInfo.textDescription;

    if (self.cardInfo.isMinion.boolValue)
    {
        self.minionImage.image = [UIImage imageNamed:self.cardInfo.name];
        self.weaponImage.image = nil;
        self.spellImageView.image = nil;
        self.cardFrame.image = [UIImage imageNamed:@"cardframe_minion.png"];
        self.legendaryFrame.hidden = ![self.cardInfo.rarity isEqualToString:LEGENDARY];
        self.attackLabel.text = [NSString stringWithFormat:@"%d", self.cardInfo.attack.intValue];
        self.healthLabel.text = [NSString stringWithFormat:@"%d", self.cardInfo.healthDurability.intValue];
        
        self.rarityImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.cardInfo.rarity]];
        self.spellRarityImage.image = nil;
    }
    else if (self.cardInfo.isWeapon.boolValue)
    {
        self.weaponImage.image = [UIImage imageNamed:self.cardInfo.name];
        self.minionImage.image = nil;
        self.spellImageView.image = nil;
        
        self.cardFrame.image = [UIImage imageNamed:@"cardframe_weapon.png"];
        self.legendaryFrame.hidden = YES;
    }
    else if (self.cardInfo.isSpell.boolValue)
    {
        self.spellImageView.image = [UIImage imageNamed:self.cardInfo.name];
        self.weaponImage.image = nil;
        self.minionImage.image = nil;
        
        self.cardFrame.image = [UIImage imageNamed:@"cardframe_spell.png"];
        self.legendaryFrame.hidden = YES;
        
        self.titleCardImageView.image = nil;
        self.titleSpellImageView.image = [UIImage imageNamed:title];
        
        self.rarityImageView.image = nil;
        self.spellRarityImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"spell_%@.png",self.cardInfo.rarity]];

    }
    else
    {
        self.minionImage.image = nil;
        self.weaponImage.image = nil;
        self.cardFrame.image = nil;
        self.legendaryFrame.hidden = YES;
    }
}

@end
