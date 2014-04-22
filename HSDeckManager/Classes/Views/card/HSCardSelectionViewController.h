//
//  HSCardSelectionViewController.h
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSDeck;
@class HSCard;

@interface HSCardSelectionViewController : UIViewController
@property (nonatomic, strong) HSDeck *deck;
@property (nonatomic, strong) HSCard *selectedCard;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *selectionCardButtons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoCardLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *addDeckCardButton;

- (void)foundCard:(HSCard *)aCard;


@end