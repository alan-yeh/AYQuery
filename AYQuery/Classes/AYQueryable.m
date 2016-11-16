//
//  AYQueryable.m
//  AYQuery
//
//  Created by Alan Yeh on 16/7/20.
//
//

#import "AYQueryable.h"
#import "AYPair.h"
#import "AYQueryableExtension.h"
#import <AYRuntime/AYRuntime.h>

@interface AYQueryable ()
@property (nonatomic, retain) NSArray *queryable;
@end

@implementation AYQueryable

- (instancetype)initWithDatasource:(NSArray *)datasource{
    NSParameterAssert([datasource isKindOfClass:[NSArray class]]);
    if (self = [super init]) {
        self.queryable = [datasource copy];
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len{
    state->mutationsPtr = (unsigned long *)&state->mutationsPtr;
    
    NSUInteger itemCount = self.queryable.count;
    NSInteger count = MIN(len, itemCount - state->state);
    
    if (count > 0) {
        for (NSUInteger i = 0, p = state->state; i < count; i++, p++) {
            buffer[i] = self.queryable[i];
        }
        state->state += count;
    }else{
        count = 0;
    }
    state->itemsPtr = buffer;
    return count;
}

- (id)objectAtIndexedSubscript:(NSInteger)idx{
    if (idx < 0) {
        if (- idx > self.queryable.count) {
            return nil;
        }else{
            return self.queryable[self.queryable.count + idx];
        }
    }else{
        if (idx >= self.queryable.count) {
            return nil;
        }else{
            return self.queryable[idx];
        }
    }
}

- (void (^)(id))each{
    return ^(void(^each)(id)){
        [self.queryable enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self _invocak_block:each withArg:obj andReturn:NULL];
        }];
    };
}

- (void (^)(id))reverseEach{
    return ^(void(^each)(id)){
        NSEnumerator *reversedEnumerator = self.queryable.reverseObjectEnumerator;
        id obj;
        while ((obj = reversedEnumerator.nextObject)) {
            [self _invocak_block:each withArg:obj andReturn:NULL];
        }
    };
}

- (void)_invocak_block:(id)block withArg:(id)arg andReturn:(void *)returnVal{
    AYBlockInvocation *block_invocation = [AYBlockInvocation invocationWithBlock:block];
    
    NSUInteger arg_count = block_invocation.signature.numberOfArguments;
    
    if (arg_count > 1){
        [block_invocation setArgument:&arg atIndex:1];
    }
    
//warning 这里可能有内存泄漏的BUG
//    if (![block_invocation argumentsRetained]) {
//        [block_invocation retainArguments];
//    }
    
    [block_invocation invoke];
    if (returnVal != NULL) {
        [block_invocation getReturnValue:returnVal];
    }
}

@end

@implementation AYQueryable (Filter)
- (id (^)(BOOL (^)(id)))find{
    return ^id (BOOL (^find)(id)){
        for (id value in self.queryable) {
            BOOL isSatified = NO;
            [self _invocak_block:find withArg:value andReturn:&isSatified];
            if (isSatified) {
                return value;
            }
        }
        return nil;
    };
}

- (AYQueryable *(^)(BOOL (^)(id)))findAll{
    return ^(BOOL (^findAll)(id)){
        NSMutableArray *result = [NSMutableArray new];
        for (id value in self.queryable) {
            BOOL isSatified = NO;
            [self _invocak_block:findAll withArg:value andReturn:&isSatified];
            if (isSatified) {
                [result addObject:value];
            }
        }
        return result.query;
    };
}

- (AYQueryable * (^)(Class))ofType{
    return ^(Class class){
        return self.findAll(^(id item){
            return [item isKindOfClass:class];
        });
    };
}

- (AYQueryable *(^)(id))exclude{
    return ^(id/*<AYQuery>*/ item){
        if (item == nil) {
            return self.query;
        }
        
        NSSet *removedMe = nil;
        if ([item conformsToProtocol:@protocol(AYQuery)]) {
            id<AYQuery> queryable = item;
            removedMe = queryable.query.toSet();
        }else{
            removedMe = [NSSet setWithObject:item];
        }
        
        if (removedMe.count < 1) {
            return self;
        }
        
        NSMutableArray *result = [NSMutableArray new];
        if (self.queryable > 0 ) {
            for (id value in self.queryable) {
                if (![removedMe containsObject:value]) {
                    [result addObject:value];
                }
            }
        }
        return result.query;
    };
}

- (AYQueryable * (^)(id<AYQuery>))intersect{
    return ^(id<AYQuery> collection){
        AYQueryable *query = collection.query;
        if (self.queryable.count < 1 || query.count < 1) {
            return @[].query;
        }
        
        NSMutableSet *result = [NSMutableSet set];
        
        NSSet *self_data = self.toSet();
        NSSet *collection_set = query.toSet();
        
        for (id value in self_data) {
            if ([collection_set containsObject:value]) {
                [result addObject:value];
            }
        }
        
        return result.query;
    };
}

- (AYQueryable *(^)(id (^)(id)))select{
    return ^(id (^select)(id)){
        NSMutableArray *result = [NSMutableArray new];
        for (id value in self.queryable) {
            __unsafe_unretained id target;
            [self _invocak_block:select withArg:value andReturn:&target];
            [result addObject:target];
        }
        return result.query;
    };
}

- (AYQueryable *(^)(id (^)(id)))selectMany{
    return ^(id (^selectMany)(id)){
        NSMutableArray *result = [NSMutableArray new];
        for (id value in self.queryable) {
            __unsafe_unretained id<AYQuery> target;
            [self _invocak_block:selectMany withArg:value andReturn:&target];
            if ([target conformsToProtocol:@protocol(AYQuery)]) {
                [result addObjectsFromArray:target.query.queryable];
            }else{
                [result addObject:target];
            }
        }
        return result.query;
    };
}

- (AYQueryable *(^)(id (^)(id)))groupBy{
    return ^(id (^groupBy)(id)) {
        NSMutableDictionary *group = [NSMutableDictionary new];
        for (id value in self.queryable) {
            
            __unsafe_unretained id groupKey;
            [self _invocak_block:groupBy withArg:value andReturn:&groupKey];
            
            NSMutableArray *groupArray = group[groupKey];
            if (groupArray == nil) {
                groupArray = [NSMutableArray new];
                group[groupKey] = groupArray;
            }
            [groupArray addObject:value];
        }
        return group.query;
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
        return self.findAll(^BOOL(id e){
            return (index ++) >= count;
        });
    };
}

- (AYQueryable *(^)(BOOL (^)(id)))skipWhile{
    return ^(BOOL (^skip)(id)) {
        __block BOOL isSkip = YES;
        return self.findAll(^BOOL(id e){
            return isSkip ? (isSkip = skip(e)) : isSkip;
        });
    };
}

- (AYQueryable *(^)(NSUInteger))take{
    return ^(NSUInteger count){
        __block NSUInteger index = 0;
        return self.findAll(^BOOL(id e){
            return (index ++) < count;
        });
    };
}

- (AYQueryable *(^)(BOOL (^)(id)))takeWhile{
    return ^(BOOL (^take)(id)) {
        __block BOOL isTake = YES;
        return self.findAll(^BOOL(id e){
            return isTake ? (isTake = take(e)) : isTake;
        });
    };
}

- (AYQueryable *(^)(NSUInteger, NSUInteger))rangeOf{
    return ^(NSUInteger skip, NSUInteger take){
        return self.skip(skip).take(take);
    };
}

- (AYQueryable * (^)())distinct{
    return ^(){
        NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithArray:self.queryable];
        return result.query;
    };
}

- (AYQueryable *(^)(NSComparisonResult (^)(id, id)))orderBy{
    return ^(NSComparisonResult (^cmptr)(id, id)){
        NSArray *result = [self.queryable sortedArrayUsingComparator:cmptr];
        return result.query;
    };
}

- (AYQueryable * (^)())reverse{
    return ^(){
        NSEnumerator *reversedEnumerator = self.queryable.reverseObjectEnumerator;
        NSMutableArray *result = [NSMutableArray new];
        id obj;
        while ((obj = reversedEnumerator.nextObject)) {
            [result addObject:obj];
        }
        return result.query;
    };
}

- (AYQueryable *(^)())flatten{
    return ^(){
        NSMutableArray *result = [NSMutableArray new];
        
        for (id<AYQuery> value in self.queryable) {
            if ([value conformsToProtocol:@protocol(AYQuery)]) {
                [result addObjectsFromArray:value.query.queryable];
            }else{
                [result addObject:value];
            }
        }
        
        return result.query;
    };
}

- (AYQueryable *(^)(id))include{
    return ^(id/*<AYQuery>*/ item){
        if (item == nil) {
            return self.queryable.query;
        }
        if ([item conformsToProtocol:@protocol(AYQuery)]) {
            id<AYQuery> queryable = item;
            if (queryable.query.count < 1) {
                return self.queryable.query;
            }
            
            NSMutableArray *result = self.queryable.mutableCopy;
            [result addObjectsFromArray:queryable.query.toArray()];
            return result.query;
        }else{
            NSMutableArray *result = self.queryable.mutableCopy;
            [result addObject:item];
            return result.query;
        }
        
    };
}

@end

@implementation AYQueryable (Operation)

- (id (^)())first{
    return ^(){
        return self[0];
    };
}

- (id (^)(id))firstOrDefault{
    return ^(id defaultValue){
        return self[0] ?: defaultValue;
    };
}

- (id (^)())last{
    return ^(){
        return self[-1];
    };
}

- (id (^)(id))lastOrDefault{
    return ^(id defaultValue){
        return self[-1] ?: defaultValue;
    };
}

- (id (^)(NSUInteger))get{
    return ^(NSUInteger index){
        return self[index];
    };
}

- (id  _Nonnull (^)(NSUInteger, id _Nonnull))getOrDefault{
    return ^(NSUInteger index, id defaultValue){
        return self[index] ?: defaultValue;
    };
}

- (id (^)(NSComparisonResult (^)(id, id)))max{
    return ^id(NSComparisonResult (^cmptr)(id, id)){
        if (self.queryable.count < 1) {
            return nil;
        }
        NSArray *result = [self.queryable sortedArrayUsingComparator:cmptr];
        return result.firstObject;
    };
}

- (id (^)(NSComparisonResult (^)(id, id)))min{
    return ^id(NSComparisonResult (^cmptr)(id, id)){
        if (self.queryable.count < 1) {
            return nil;
        }
        self.queryable = [self.queryable sortedArrayUsingComparator:cmptr];
        return self.queryable.lastObject;
    };
}

- (BOOL (^)(id))contains{
    return ^(id object) {
        return [self.queryable containsObject:object];
    };
}

- (BOOL (^)(BOOL(^)(id)))any{
    return ^BOOL(BOOL(^any)(id)){
        if (self.queryable.count < 1) {
            return NO;
        }
        for (id value in self.queryable) {
            BOOL isSatisfied = NO;
            [self _invocak_block:any withArg:value andReturn:&isSatisfied];
            if (isSatisfied) {
                return YES;
            }
        }
        return NO;
    };
}

- (BOOL (^)(BOOL (^)(id)))all{
    return ^BOOL(BOOL (^all)(id)){
        if (self.queryable.count < 1) {
            return YES;
        }
        for (id value in self.queryable) {
            BOOL isSatisfied = NO;
            [self _invocak_block:all withArg:value andReturn:&isSatisfied];
            if (!isSatisfied) {
                return NO;
            }
        }
        return YES;
    };
}


- (NSString *(^)(NSString *))join{
    return ^(NSString *seperator){
        NSMutableString *result = [NSMutableString string];
        for (id value in self.queryable) {
            if (result.length > 0) {
                [result appendString:seperator];
            }
            [result appendFormat:@"%@", value];
        }
        return result.copy;
    };
}

@end

@implementation AYQueryable (Convert)
- (NSDictionary *(^)(AYPair *(^)(id)))toDictionary{
    return ^(id (^dictionary)(id)) {
        NSMutableDictionary *result = [NSMutableDictionary new];
        if (dictionary) {
            for (id value in self.queryable) {
                AYPair *pair;
                [self _invocak_block:dictionary withArg:value andReturn:&pair];
                NSAssert([pair isKindOfClass:[AYPair class]], @"无法转换成dictionary：请返回AYPair类型");
                [result setObject:pair.value forKey:pair.key];
            }
        }else{
            for (AYPair *pair in self.queryable) {
                NSAssert([pair isKindOfClass:[AYPair class]], @"无法转换成dictionary：queryable中的元素不是AYPair类型");
                [result setObject:pair.value forKey:pair.key];
            }
        }
        return result.copy;
    };
}

- (NSArray *(^)())toArray{
    return ^(){
        return self.queryable;
    };
}

- (NSSet *(^)())toSet{
    return ^(){
        return [NSSet setWithArray:self.queryable];
    };
}
@end
