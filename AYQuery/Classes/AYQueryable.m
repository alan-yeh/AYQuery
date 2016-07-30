//
//  AYQueryable.m
//  AYQuery
//
//  Created by PoiSon on 16/7/20.
//
//

#import "AYQueryable.h"
#import "AYTuple.h"
#import "AYQueryAction.h"
#import "AYQuerySelectAction.h"
#import "AYQueryWhereAction.h"
#import "AYEnumerable.h"

/**
 * 具有延迟计算的运算符
 * Cast，Concat，DefaultIfEmpty，Distinct，Except，GroupBy，GroupJoin，Intersect，
 * Join，OfType，OrderBy，OrderByDescending，Repeat，Reverse，Select，SelectMany，Skip，
 * SkipWhile，Take，TakeWhile，ThenBy，ThenByDescending，Union，Where，Zip
 *
 *
 * 立即执行的运算符
 * Aggregate，All，Any，Average，Contains，Count，ElementAt，ElementAtOrDefault，
 * Empty，First，FirstOrDefault，Last，LastOrDefault，LongCount，Max，Min，Range，
 * SequenceEqual，Single，SingleOrDefault，Sum，ToArray，ToDictionary，ToList，ToLookup
 */
@interface AYQueryable ()
@property (nonatomic, retain) NSArray<AYTuple *> *queryable;
@property (nonatomic, retain) AYQueryAction *action;
@end

@implementation AYQueryable
- (instancetype)initWithDatasource:(NSArray<AYTuple *> *)datasource{
    if (self = [super init]) {
        self.queryable = datasource;
    }
    return self;
}

- (AYQueryAction *)action{
    return _action ?: (_action = [AYQueryAction new]);
}

- (void)executeAction:(void (^)(AYTuple *tuple, BOOL *stop))action{
    self.action.nextAction = [AYQueryAction new];
    
    NSMutableArray *new_queryable = [NSMutableArray new];
    
    for (NSUInteger i = 0, count = self.queryable.count; i < count; i ++) {
        AYTuple *tuple = self.queryable[i];
        AYTuple *result = [self.action execute:tuple];
        if (result == nil) {
            continue;
        }
        [new_queryable addObject:result];
        
        BOOL stop = NO;
        if (action) {
            action(result, &stop);
        }
        if (stop) {
            break;
        }
    }
    
    self.queryable = new_queryable;
    self.action = nil;
}

#pragma mark - NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len{
    state->mutationsPtr = (unsigned long *)&state->mutationsPtr;
    
    NSUInteger itemCount = self.queryable.count;
    NSInteger count = MIN(len, itemCount - state->state);
    
    if (count > 0) {
        for (NSUInteger i = 0, p = state->state; i < count; i++, p++) {
            buffer[i] = self.queryable[i].value;
        }
        state->state += count;
    }else{
        count = 0;
    }
    state->itemsPtr = buffer;
    return count;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx{
    return self.queryable[idx];
}

- (void)foreach:(void (^)(id, NSUInteger, BOOL *))foreach{
    __block NSUInteger idx = 0;
    [self executeAction:^(AYTuple *tuple, BOOL *stop) {
        foreach(tuple.value, idx ++, stop);
    }];
}
@end

@implementation AYQueryable (Select)
- (AYQueryable *(^)(BOOL (^)(id)))where{
    return ^(BOOL (^where)(id)){
        self.action.nextAction = [AYQueryWhereAction actionWithBlock:where];
        return self;
    };
}

- (AYQueryable *(^)(id (^)(id)))select{
    return ^(id (^select)(id)){
        self.action.nextAction = [AYQuerySelectAction actionWithBlock:select];
        return self;
    };
}

- (AYQueryable *(^)(__unsafe_unretained Class))ofType{
    return ^(Class class){
        return self.where(^(id e){
            return [e isKindOfClass:class];
        });
    };
}

- (AYQueryable *(^)(id (^)(id)))groupBy{
    return ^(id (^groupBy)(id)) {
        NSMutableDictionary *group = [NSMutableDictionary new];
        [self executeAction:^(AYTuple *tuple, BOOL *stop) {
            id key = groupBy(tuple.value);
            NSMutableArray *groupArray = group[key];
            if (groupArray == nil) {
                groupArray = [NSMutableArray new];
                group[key] = groupArray;
            }
            [groupArray addObject:tuple.value];
        }];
        self.queryable = group.query.queryable;
        return self;
    };
}
@end

@implementation AYQueryable (Range)
- (NSUInteger)count{
    return self.queryable.count;
}

- (AYQueryable *(^)(NSUInteger))skip{
    return ^(NSUInteger count){
        __block NSUInteger index = 0;
        return self.where(^BOOL(id e){
            return (index ++) >= count;
        });
    };
}

- (AYQueryable *(^)(BOOL (^)(id)))skipWhile{
    return ^(BOOL (^skip)(id)) {
        __block BOOL isSkip = YES;
        return self.where(^BOOL(id e){
            return isSkip ? (isSkip = skip(e)) : isSkip;
        });
    };
}

- (AYQueryable *(^)(NSUInteger))take{
    return ^(NSUInteger count){
        __block NSUInteger index = 0;
        return self.where(^BOOL(id e){
            return (index ++) < count;
        });
    };
}

- (AYQueryable *(^)(BOOL (^)(id)))takeWhile{
    return ^(BOOL (^take)(id)) {
        __block BOOL isTake = YES;
        return self.where(^BOOL(id e){
            return isTake ? (isTake = take(e)) : isTake;
        });
    };
}

- (AYQueryable *(^)(NSUInteger, NSUInteger))rangeOf{
    return ^(NSUInteger skip, NSUInteger take){
        return self.skip(skip).take(take);
    };
}
@end

@implementation AYQueryable (Operation)

- (id)first{
    [self executeAction:nil];
    return self.queryable.firstObject.value;
}

- (id)last{
    [self executeAction:nil];
    return self.queryable.lastObject.value;
}

- (id (^)(NSUInteger))at{
    return ^(NSUInteger index){
        [self executeAction:nil];
        return [self.queryable objectAtIndex:index];
    };
}

- (id (^)(NSComparisonResult (^)(id, id)))max{
    return ^(NSComparisonResult (^cmptr)(id, id)){
        [self executeAction:nil];
        self.queryable = [self.queryable sortedArrayUsingComparator:cmptr];
        return self.queryable.firstObject;
    };
}

- (id (^)(NSComparisonResult (^)(id, id)))min{
    return ^(NSComparisonResult (^cmptr)(id, id)){
        [self executeAction:nil];
        self.queryable = [self.queryable sortedArrayUsingComparator:cmptr];
        return self.queryable.lastObject;
    };
}

- (BOOL (^)(id))contains{
    return ^(id object) {
        [self executeAction:nil];
        return [self.queryable containsObject:AYTupleObject(object)];
    };
}

- (AYQueryable *(^)(NSComparisonResult (^)(id, id)))orderBy{
    return ^(NSComparisonResult (^cmptr)(id, id)){
        [self executeAction:nil];
        self.queryable = [self.queryable sortedArrayUsingComparator:cmptr];
        return self;
    };
}

- (AYQueryable *)distinct{
    NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
    [self executeAction:^(AYTuple *tuple, BOOL *stop) {
        [set addObject:tuple];
    }];
    return set.query;
}

- (AYQueryable *)reverse{
    [self executeAction:nil];
    NSEnumerator *reversedEnumerator = self.queryable.reverseObjectEnumerator;
    NSMutableArray<AYTuple *> *result = [NSMutableArray new];
    id obj;
    while ((obj = reversedEnumerator.nextObject)) {
        [result addObject:obj];
    }
    self.queryable = result;
    return self;
}
@end

@implementation AYQueryable (Convert)
- (NSDictionary *(^)(AYTuple *(^)(id)))dictionary{
    return ^(AYTuple *(^dictionary)(id)) {
        NSMutableDictionary *result = [NSMutableDictionary new];
        [self executeAction:^(AYTuple *tuple, BOOL *stop) {
            AYTuple *key_value = dictionary(tuple);
            id key = key_value.value[@"Key"];
            id value = key_value.value[@"Value"];
            result[key] = value;
        }];
        return result;
    };
}

- (NSArray *)array{
    NSMutableArray *result = [NSMutableArray new];
    [self executeAction:^(AYTuple *tuple, BOOL *stop) {
        [result addObject:tuple.value];
    }];
    return result.copy;
}

- (NSSet *)set{
    NSMutableSet *result = [NSMutableSet new];
    [self executeAction:^(AYTuple *tuple, BOOL *stop) {
        [result addObject:tuple.value];
    }];
    return result;
}
@end