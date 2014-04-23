//
//  HSDataCenter.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSDataCenter.h"
#import "HSCardInfo.h"
#import "HSRate.h"
#import "HSDeck.h"
#import "HSCard.h"

typedef enum
{
    hsCardTypeMinion    = 1,
    hsCardTypeSpell     = 2,
    hsCardTypeWeapon    = 3,
    hsCardTypeSecret    = 4
} hsCardType;

@implementation HSDataCenter

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSArray*)heroIDList
{
    return @[@"druid", @"hunter", @"mage", @"paladin", @"priest", @"rogue", @"shaman", @"warlock", @"warrior"];
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self loadCardInfo];
        [self loadRateInfo];
    }
    return self;
}

#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HSDeckManagerData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HSDeckManagerData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark Query
#pragma mark - Load Info
- (void)loadCardInfo
{
    BOOL alreadyLoadInfo = [[NSUserDefaults standardUserDefaults] boolForKey:@"hsCardInfoDidLoad"];
    if (alreadyLoadInfo)
        return;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"card_data" ofType:@"data"];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    for (NSString *line in lines)
    {
        NSArray *components = [line componentsSeparatedByString:@"|"];
        if (components.count < 8)
            continue;
        
        HSCardInfo *info = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HSCardInfo class]) inManagedObjectContext:self.managedObjectContext];
        int cardType = [components[0] intValue];
        info.isMinion   = @(hsCardTypeMinion == cardType);
        info.isWeapon   = @(hsCardTypeWeapon == cardType);
        info.isSecret   = @(hsCardTypeSecret == cardType);
        info.isSpell    = @(hsCardTypeSpell == cardType);
        
        info.name               = components[1];
        info.manaCost           = @([components[2] intValue]);
        info.attack             = @([components[3] intValue]);
        info.healthDurability   = @([components[4] intValue]);
        
        info.classCard = components[5];
        info.rarity    = components[6];
        info.fullname  = components[7];
        
        if (components.count > 8) {
            NSString *des = components[8];
            info.textDescription  = des;
            info.hasOverload = @([des rangeOfString:@"Overload"].location != NSNotFound);
            info.isTaunt = @([des rangeOfString:@"Taunt"].location != NSNotFound);
            info.isStealth = @([des rangeOfString:@"Stealth"].location != NSNotFound);
            info.hasCharge = @([des rangeOfString:@"Charge"].location != NSNotFound && ![info.name isEqualToString:@"WarsongCommander"]);
            info.isTaunt = @([des rangeOfString:@"Taunt"].location != NSNotFound);
            info.isSecret = @([des rangeOfString:@"Secret:"].location != NSNotFound);
            info.hasSilence = @([des rangeOfString:@"Silence"].location != NSNotFound);
            info.hasEnrage = @([des rangeOfString:@"Enrage"].location != NSNotFound);
            info.hasBattlecry = @([des rangeOfString:@"Battlecry:"].location != NSNotFound);
        }
        
        // Check AOE
        if ([info.name isEqualToString:@"ArcaneExplosion"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Whirlwind"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Swipe"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"FanOfKnives"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Hellfire"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"HolyNova"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Flamestrike"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Blizzard"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"FrostNova"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"ExplosiveTrap"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Consecration"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"ConeOfCold"]) {
            info.isAoE = @(YES);
        } else if ([info.name isEqualToString:@"Abomination"]) {
            info.isAoE = @(YES);
        }
    }
    
    [self saveContext];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hsCardInfoDidLoad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadRateInfo
{
    BOOL alreadyLoadInfo = [[NSUserDefaults standardUserDefaults] boolForKey:@"hsCardRateDidLoad"];
    if (alreadyLoadInfo)
        return;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rate" ofType:@"csv"];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    for (NSString *line in lines)
    {
        NSArray *components = [line componentsSeparatedByString:@","];
        if (components.count < 8)
            continue;
        
        HSRate *info = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([HSRate class]) inManagedObjectContext:self.managedObjectContext];
        
        info.name               = components[0];
        info.rateDruid          = @([components[1] floatValue]);
        info.rateHunter         = @([components[2] floatValue]);
        info.rateMage           = @([components[3] floatValue]);
        info.ratePaladin        = @([components[4] floatValue]);
        info.ratePriest         = @([components[5] floatValue]);
        info.rateRogue          = @([components[6] floatValue]);
        info.rateShaman         = @([components[7] floatValue]);
        info.rateWarlock        = @([components[8] floatValue]);
        info.rateWarrior        = @([components[9] floatValue]);
    }
    
    [self saveContext];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hsCardRateDidLoad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)rateForCardInfo:(HSCardInfo *)cardInfo withClass:(NSString *)classHero
{
    float res = 0.00;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([HSRate class]) inManagedObjectContext:self.managedObjectContext]];
    // Delete space from text
    NSString *key = [NSString stringWithFormat:@"rate%@",[classHero capitalizedString]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", cardInfo.name]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:key,nil]];
    
    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (objects.count > 0)
        res = [[[objects objectAtIndex:0] objectForKey:key] floatValue];

    return res;
}

#pragma mark - Get Info
- (NSString *)rateStringFromValue:(float)value
{
    NSString *res = nil;
    
    // Top 80 - 89, Great 70 - 79, Good 60 69, Usually good 59 - 59.95, Above Average: 50 - 59, Average 40 -49, Below average 30- 49, Usually bad : 20 - 29 Bad 10 19 Terrible 5 9
    if (value > 90 || value == 90) {
        res = @"Must have";
    } else if ((value == 80 || value > 80) && value < 90) {
        res = @"Top";
    } else if ((value == 70 || value > 70) && value < 80) {
        res = @"Great";
    } else if ((value == 60 || value > 60) && value < 70) {
        res = @"Good";
    } else if ( value > 59 && value < 60) {
        res = @"Usually good";
    } else if ((value == 50 || value > 50) && (value < 59 || value == 59)) {
        res = @"Above average";
    } else if ((value == 40 || value > 40) && value < 50) {
        res = @"Average";
    } else if ((value == 30 || value > 30) && value < 40) {
        res = @"Below average";
    } else if ((value == 20 || value > 20) && value < 30) {
        res = @"Not very bad";
    } else if ((value == 10 || value > 10) && value < 20) {
        res = @"Bad";
    } else {
        res = @"Terrible";
    }
    
    return res;
}

- (NSMutableDictionary *)dictionaryStatsFromDeck:(HSDeck *)aDeck
{
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([HSCard class])
                                        inManagedObjectContext:self.managedObjectContext]];
    // Fetch
    NSArray *keyArray = [NSArray arrayWithObjects:@"isMinion",@"isSpell",@"isSpell",@"isWeapon",@"hasBattlecry",@"hasOverload",@"isTaunt",@"isStealth",@"hasCharge",@"isSecret", @"hasSilence", @"hasEnrage", @"isAoE",nil];
    
    NSError *error = nil;
    for (NSString *key in keyArray) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentDeck = %@ AND cardInfo.%@ == YES", aDeck, key]];
        NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        [res setObject:@(count) forKey:key];
    }
    
    return res;
}


@end