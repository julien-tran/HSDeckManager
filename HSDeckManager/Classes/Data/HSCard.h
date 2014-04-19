//
//  HSCard.h
//  HSDeckManager
//
//  Created by Julien Tran on 19/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HSCardInfo, HSDeck;

@interface HSCard : NSManagedObject

@property (nonatomic, retain) HSDeck *parentDeck;
@property (nonatomic, retain) HSCardInfo *cardInfo;

@end
