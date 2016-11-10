//
//  AYEnumerable.m
//  AYQuery
//
//  Created by Alan Yeh on 16/7/30.
//
//

#import "AYQueryableExtension.h"
#import "AYQueryable.h"
#import "AYPair.h"

@implementation NSArray (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:value];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSDictionary (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id key in self) {
        [datasource addObject:[AYPair key:key value:self[key]]];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSSet (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:value];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSOrderedSet (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:value];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSHashTable (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id value in self) {
        [datasource addObject:value];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation NSMapTable (AYQuery)
- (AYQueryable *)query{
    NSMutableArray *datasource = [NSMutableArray new];
    for (id key in self) {
        [datasource addObject:[AYPair key:key value:[self objectForKey:key]]];
    }
    return [[AYQueryable alloc] initWithDatasource:datasource];
}
@end

@implementation AYQueryable (AYQuery)
- (AYQueryable *)query{
    return self;
}
@end
