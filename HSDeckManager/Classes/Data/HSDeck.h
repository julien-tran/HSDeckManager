//
//  HSDeck.h
//  HSDeckManager
//
//  Created by Julien Tran on 19/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HSCard;

@interface HSDeck : NSManagedObject

@property (nonatomic, retain) NSString * hero;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cards;
@end

@interface HSDeck (CoreDataGeneratedAccessors)

- (void)addCardsObject:(HSCard *)value;
- (void)removeCardsObject:(HSCard *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end
