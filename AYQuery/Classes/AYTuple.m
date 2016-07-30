//
//  AYTuple.m
//  AYQuery
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYTuple.h"
#import "AYEnumerable.h"
#import "AYQueryable.h"

@interface AYTuple()
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) id object;
@end

@implementation AYTuple
- (id)value{
    return self.object ?: self.objects;
}

+ (instancetype)tupleWithObjects:(NSArray *)objects{
    NSAssert(objects.count, @"can not pack nil values");
    AYTuple *tuple = [self new];
    if (objects.count == 1) {
        tuple.object = objects[0];
    }else{
        tuple.objects = objects;
    }
    return tuple;
}

+ (instancetype)tupleWithObjects:(NSArray *)objects forKeys:(NSArray *)keys{
    NSAssert(objects.count > 0, @"can not pack nil objects");
    NSAssert(objects.count == keys.count, @"pack failed cause key and object are not match.");
    AYTuple *tuple = [self new];
    
    tuple.object = [NSMutableDictionary dictionary];
    [keys.query.select(^(id e){
        return [[e componentsSeparatedByString:@"="][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }) foreach:^(id e, NSUInteger idx, BOOL *stop) {
        id value = objects[idx];
        if (value != nil) {
            [tuple.object setValue:value forKey:e];
        }
    }];
    return tuple;
}
@end

@implementation _ay_tuple_trampoline
+ (instancetype)trampoline{
    static _ay_tuple_trampoline *trampoline = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trampoline = [_ay_tuple_trampoline new];
    });
    return trampoline;
}

- (void)setObject:(id)pack forKeyedSubscript:(NSArray<NSValue *> *)variables{
    NSParameterAssert(variables);
    NSAssert([pack isKindOfClass:[NSArray class]], @"Can not unpack cause it was not an array tuple.");
    
    [variables enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong id *ptr = (__strong id *)obj.pointerValue;
        *ptr = pack[idx];
    }];
}
@end