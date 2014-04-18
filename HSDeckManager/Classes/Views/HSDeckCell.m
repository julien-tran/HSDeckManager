//
//  HSDeckCell.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSDeckCell.h"
#import "HSDeck.h"

@interface HSDeckCell ()

@end

@implementation HSDeckCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithDeck:(HSDeck*)deck
{
    self.deckNameLabel.text = deck.name;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy - HH:mm"];
    self.deckDateLabel.text = [formatter stringFromDate:deck.lastDate];
    self.deckCardsLabel.text = [NSString stringWithFormat:@"%d/30 cards", deck.cards.count];
}

@end