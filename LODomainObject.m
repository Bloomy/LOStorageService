//
//  LODomainObject.m
//  Temporary CoreData
//

#import "LODomainObject.h"
#import "LOStorageService.h"

@implementation LODomainObject

+ (NSString *)entityName
{
    return CLASS_STRING(self);
}


+ (id)temporaryEntity
{
    NSManagedObjectContext *context = [[LOStorageService sharedInstance] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];

    return [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
}


- (void)addToContext:(NSManagedObjectContext *)context
{
    [context insertObject:self];
}


@end
