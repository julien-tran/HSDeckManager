//
//  HSDataCenter.h
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <Foundation/Foundation.h>


#define LEGENDARY   @"legendary"
#define EPIC        @"epic"
#define RARE        @"rare"
#define COMMON      @"common"

@class HSCardInfo;
@class HSDeck;

@interface HSDataCenter : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

+ (instancetype)sharedInstance;
+ (NSArray*)heroIDList;
- (void)saveContext;

- (float)rateForCardInfo:(HSCardInfo *)cardInfo withClass:(NSString *)classHero;
- (NSString *)rateStringFromValue:(float)value;
- (NSMutableDictionary *)dictionaryStatsFromDeck:(HSDeck *)aDeck;

@end