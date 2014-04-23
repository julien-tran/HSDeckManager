//
//  HSCardCell.m
//  HSDeckManager
//
//  Created by Julien Tran on 19/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSCardCell.h"
#import "HSCard.h"
#import "HSCardInfo.h"
#import "HSDataCenter.h"

@interface HSCardCell ()
@property (nonatomic, weak) IBOutlet UILabel        *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel        *manaCostLabel;
@property (nonatomic, weak) IBOutlet UIImageView    *cardImage;
@end

@implementation HSCardCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithCard:(HSCard*)card
{
    HSCardInfo *info = card.cardInfo;
    self.nameLabel.text = info.fullname;
    self.manaCostLabel.text = [NSString stringWithFormat:@"%d", info.manaCost.intValue];
    self.cardImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",info.name]];
    
    if ([info.rarity isEqualToString:LEGENDARY])
        self.nameLabel.textColor = [UIColor orangeColor];
    else if ([info.rarity isEqualToString:EPIC])
        self.nameLabel.textColor = [UIColor purpleColor];
    else if ([info.rarity isEqualToString:RARE])
        self.nameLabel.textColor = [UIColor blueColor];
    else
        self.nameLabel.textColor = [UIColor whiteColor];
}

@end