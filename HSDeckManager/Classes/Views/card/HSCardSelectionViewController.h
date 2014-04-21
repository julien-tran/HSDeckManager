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
@property (weak, nonatomic) IBOutlet UILabel *cardOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardThreeLabel;

- (void)foundCard:(HSCard *)aCard;


@end