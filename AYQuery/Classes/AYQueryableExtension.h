//
//  AYEnumerable.h
//  AYQuery
//
//  Created by Alan Yeh on 16/7/30.
//
//

#import <Foundation/Foundation.h>
#import <AYQuery/AYQueryable.h>


@protocol AYQuery <NSObject>
@property (readonly) AYQueryable *query;
@end

FOUNDATION_EXPORT AYQueryable *AYQueryMake(id<AYQuery> query);


#pragma mark - Supported collections types
@interface NSArray (AYQuery) <AYQuery> @end
@interface NSDictionary (AYQuery) <AYQuery> @end
@interface NSSet (AYQuery) <AYQuery> @end
@interface NSOrderedSet (AYQuery) <AYQuery> @end
@interface NSHashTable (AYQuery) <AYQuery> @end
@interface NSMapTable (AYQuery) <AYQuery> @end
@interface AYQueryable (AYQuery) <AYQuery> @end
