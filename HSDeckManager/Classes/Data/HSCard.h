//
//  HSCard.h
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HSDeck;

@interface HSCard : NSManagedObject

@property (nonatomic, retain) NSNumber * manaCost;
@property (nonatomic, retain) NSNumber * isTaunt;
@property (nonatomic, retain) NSNumber * isDivine;
@property (nonatomic, retain) NSNumber * isMinion;
@property (nonatomic, retain) NSNumber * isWeapon;
@property (nonatomic, retain) NSNumber * isSpell;
@property (nonatomic, retain) NSNumber * isSecret;
@property (nonatomic, retain) NSNumber * canDrawCard;
@property (nonatomic, retain) NSNumber * isAoE;
@property (nonatomic, retain) NSNumber * isRemoval;
@property (nonatomic, retain) NSNumber * canSilence;
@property (nonatomic, retain) NSNumber * hasBattlecry;
@property (nonatomic, retain) NSNumber * canHeal;
@property (nonatomic, retain) NSNumber * hasCharge;
@property (nonatomic, retain) HSDeck *parentDeck;

@end
