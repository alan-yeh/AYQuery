//
//  AYEnumerable.h
//  AYQuery
//
//  Created by PoiSon on 16/7/30.
//
//

#import <Foundation/Foundation.h>

@class AYQueryable;
@class AYKeyValuePair;

@interface NSArray (AYQuery)
@property (readonly) AYQueryable *query;
@end

@interface NSDictionary (AYQuery)
@property (readonly) AYQueryable *query;
@end

@interface NSSet (AYQuery)
@property (readonly) AYQueryable *query;
@end

@interface NSOrderedSet (AYQuery)
@property (readonly) AYQueryable *query;
@end

@interface NSHashTable (AYQuery)
@property (readonly) AYQueryable *query;
@end

@interface NSMapTable (AYQuery)
@property (readonly) AYQueryable *query;
@end