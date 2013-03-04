//
//  LOStorageService.h
//  Temporary CoreData
//
//  Basado en http://locassa.com/temporary-storage-in-apples-coredata/
//  y adaptado por Orlando Alemán Ortiz, 2012
//

#import "LODomainObject.h"


/*!
 @brief 
    Permite trabajar con objetos CoreData temporales de manera más flexible. Es una clase Singleton

 @example
     LOStorageService *storage = [LOStorageService instance];
     NSManagedObjectContext *context = [storage managedObjectContext];
     ￼ *object = NEW_ENTITY(￼, context);
     [storage save];
 */

@interface LOStorageService : NSObject

/// Da acceso al objeto LOStorage único
+ (LOStorageService *)sharedInstance;

- (NSArray *)allObjectsOfType:(Class)class;

- (void)deleteObject:(LODomainObject *)object;

/// Elimina todos los objetos de una clase del contexto
- (void)deleteAllObjectsOfType:(Class)class;

- (BOOL)save;

- (void)logNSError:(NSError *)error;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext; //!<  Devuelve el objeto contexto utilizado internamente
@end
