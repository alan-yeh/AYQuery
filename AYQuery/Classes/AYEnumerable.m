//
//  AYEnumerable.m
//  AYQuery
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYEnumerable.h"
#import "AYQueryable.h"
#import "AYTuple.h"

@implementation NSArray (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:AYTupleArray(value)];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSDictionary (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id key in self) {
        [datasource addObject:AYTupleObject(Key = key, Value = self[key])];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSSet (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:AYTupleArray(value)];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSOrderedSet (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:AYTupleArray(value)];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSHashTable (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:AYTupleArray(value)];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSMapTable (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id key in self) {
        [datasource addObject:AYTupleObject(Key = key, Value = [self objectForKey:key])];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end