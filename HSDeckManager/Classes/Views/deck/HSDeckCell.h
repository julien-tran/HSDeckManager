//
//  HSDeckCell.h
//  HSDeckManager
//
//  Created by Minh-Hang LE on 23/04/14.
//  Copyright (c) 2014 Minh-Hang LE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSDeck;

@interface HSDeckCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *deckNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *deckDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *deckCardsLabel;
- (void)updateUIWithDeck:(HSDeck*)deck;
@end