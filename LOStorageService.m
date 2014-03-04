//
//  LOStorageService.m
//  Temporary CoreData
//

#import "LOStorageService.h"


#pragma mark - Interfaces

@interface LOStorageService () {}

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *identifier;
@end



@implementation LOStorageService

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


static LOStorageService *_sharedInstance = nil;


+ (void)initialize
{
    /*
       PATRÓN SINGLETON:
       http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
     *** el método initialize se llama sólo cuando se invoca por primera vez la clase y es síncrono
     */

    static BOOL initialized = NO;

    if (!initialized) {
        initialized = YES;
        _sharedInstance = [[LOStorageService alloc] initWithIdentifier:kCoreDataIdentifier];
    }
}


+ (LOStorageService *)sharedInstance
{
    return _sharedInstance;
}


- (id)init
{
    [NSException raise:NSInternalInconsistencyException format:@"[%@ %@] cannot be called; use +[%@ %@] instead",  NSStringFromClass([self class]), NSStringFromSelector(@selector(init) ), NSStringFromClass([self class]), NSStringFromSelector(@selector(sharedInstance) )];
    return self;
}


- (id)initWithIdentifier:(NSString *)anIdentifier
{
    self = [super init];

    if (self) {
        _identifier = anIdentifier;
    }

    return self;
}


#pragma mark - CoreData stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    if (self.persistentStoreCoordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    }

    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataIdentifier withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSError *error = nil;

    NSURL *storeURL = nil;
    
    if (kLOStorageCopyFromAppBundle) {
        storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[kCoreDataIdentifier stringByAppendingPathExtension:@"sqlite"]];
    
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[storeURL path]]) {
            NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:kCoreDataIdentifier withExtension:@"sqlite"];
            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:&error];
            if (error) {
                NSLog(@"Error: %@", error.description);
                return nil;
            }
        }
    }
    else {
        storeURL = [[NSBundle mainBundle] URLForResource:kCoreDataIdentifier withExtension:@"sqlite"];
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    NSDictionary *options = @{
        NSMigratePersistentStoresAutomaticallyOption: @YES,
        NSInferMappingModelAutomaticallyOption: @YES
    };

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}



#pragma mark - Data Methods


- (void)deleteObject:(LODomainObject *)object
{
    if (self.managedObjectContext) [_managedObjectContext deleteObject:object];
}


- (void)deleteAllObjectsOfType:(Class)class
{
    NSString *entityDescription = NSStringFromClass(class);

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];

    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    for (NSManagedObject *managedObject in items) {
        [self.managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted", entityDescription);
    }
}


#pragma mark - CoreData stack

- (BOOL)save
{
    NSError *error = nil;

    if (![self.managedObjectContext save:&error]) {
        [self logNSError:error];
        return FALSE;
    }

    return TRUE;
}


- (NSArray *)allObjectsOfType:(Class)class
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];

    [request setEntity:entity];

    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (error != nil) {
        NSLog(@"There was an error retrieving all objects of type: %@, %@", NSStringFromClass(class), [error localizedDescription]);
        [self logNSError:error];
        return nil;
    }

    return fetchResults;
}


#pragma mark - Helper Methods

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)logNSError:(NSError *)error
{
    NSLog(@"%@", [error userInfo]);

    if ([error userInfo][@"NSDetailedErrors"]) {
        for (NSError *errorItem in [error userInfo][@"NSDetailedErrors"]) {
            for (NSString *key in [errorItem userInfo]) {
                NSLog(@"%@ - %@", key, [errorItem userInfo][key]);
            }
        }
    }
}


@end
