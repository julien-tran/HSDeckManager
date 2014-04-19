//
//  HSDataCenter.m
//  HSDeckManager
//
//  Created by Julien Tran on 18/04/14.
//  Copyright (c) 2014 Julien Tran. All rights reserved.
//

#import "HSDataCenter.h"
#import "HSCardInfo.h"

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
    return @[@"druid", @"hunter", @"mage", @"priest"];
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self loadCardInfo];
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

#pragma mark - Query
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
        if (5 != components.count)
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
    }
    
    [self saveContext];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hsCardInfoDidLoad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end