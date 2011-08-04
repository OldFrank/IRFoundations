//
//  IRDataStore.h
//  IRFoundations
//
//  Created by Evadne Wu on 7/21/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

//	This class is the initial implementation for the application’s data store.
//	To gain persistence and access the store, invoke the class method +defaultStore.

@interface IRDataStore : NSObject

+ (IRDataStore *) defaultStore;

- (IRDataStore *) initWithManagedObjectModel:(NSManagedObjectModel *)model;
- (NSManagedObjectModel *) defaultManagedObjectModel;
- (NSURL *) defaultPersistentStoreURL;

- (NSManagedObjectContext *) disposableMOC;

//	Internally used Core Data stuff
@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//	The “emperor” context
@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;


//	Common file operations.
//	-oneUsePersistentFileURL returns something with an UDID embedded
//	Other methods are conveniences

- (NSURL *) oneUsePersistentFileURL;
- (NSURL *) persistentFileURLForData:(NSData *)data;
- (NSURL *) persistentFileURLForFileAtURL:(NSURL *)aURL;
- (NSURL *) persistentFileURLForFileAtPath:(NSString *)aPath;

@end
