//
//  HSCardSearchViewController.h
//  HSDeckManager
//
//  Created by Julien Tran on 19/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSDeck;
@class HSCard;

@interface HSCardSearchViewController : UIViewController
@property (nonatomic, strong) HSDeck *deck;
@property (nonatomic, strong) HSCard *card;
@end