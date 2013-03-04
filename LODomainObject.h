//
//  LODomainObject.h
//  Temporary CoreData
//
//  Basado en http://locassa.com/temporary-storage-in-apples-coredata/
//  y adaptado por Orlando Alemán Ortiz, 2012
//

#ifndef LDOMAIN_UTILS
#define LDOMAIN_UTILS

#define CLASS_STRING(x) NSStringFromClass ([x class])

#define NEW_ENTITY(CLASS, CONTEXT) [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CLASS class]) inManagedObjectContext:CONTEXT]

#endif

#import <CoreData/CoreData.h>

@interface LODomainObject : NSManagedObject { }

/// Retorna el nombre del objeto
+ (NSString *)entityName;

/// Devuelve una instancia de la entidad sin un contexto asignado
+ (id)temporaryEntity;

/// Añade la instancia de entidad al contexto indicado
- (void)addToContext:(NSManagedObjectContext *)context;

@end

