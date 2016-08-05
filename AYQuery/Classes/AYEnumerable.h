//
//  AYEnumerable.h
//  AYQuery
//
//  Created by PoiSon on 16/7/30.
//
//

#import <Foundation/Foundation.h>

@class AYQueryable;

@protocol AYQuery <NSObject>
@property (readonly) AYQueryable *query;
@end

FOUNDATION_EXPORT AYQueryable *AYQueryMake(id<AYQuery> query);


#pragma mark - Supported collections types
@interface NSArray (AYQuery) <AYQuery>@end
@interface NSDictionary (AYQuery) <AYQuery>@end
@interface NSSet (AYQuery) <AYQuery>@end
@interface NSOrderedSet (AYQuery) <AYQuery>@end
@interface NSHashTable (AYQuery) <AYQuery>@end
@interface NSMapTable (AYQuery) <AYQuery>@end