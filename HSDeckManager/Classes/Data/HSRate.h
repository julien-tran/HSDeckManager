//
//  HSRate.h
//  HSDeckManager
//
//  Created by Minh-Hang LE on 22/04/2014.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HSRate : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rateDruid;
@property (nonatomic, retain) NSNumber * rateHunter;
@property (nonatomic, retain) NSNumber * rateMage;
@property (nonatomic, retain) NSNumber * ratePaladin;
@property (nonatomic, retain) NSNumber * ratePriest;
@property (nonatomic, retain) NSNumber * rateRogue;
@property (nonatomic, retain) NSNumber * rateShaman;
@property (nonatomic, retain) NSNumber * rateWarlock;
@property (nonatomic, retain) NSNumber * rateWarrior;

@end
