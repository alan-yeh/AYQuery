//
//  AYPair.m
//  Pods
//
//  Created by alan on 2016/11/9.
//
//

#import "AYPair.h"

@implementation AYPair
- (instancetype)initWithKey:(id)key andValue:(id)value{
    if (self = [super init]) {
        _key = key;
        _value = value;
    }
    return self;
}

+ (instancetype)key:(id)key value:(id)value{
    return [[self alloc] initWithKey:key andValue:value];
}

+ (instancetype)pairWithKey:(id)key andValue:(id)value{
    return [[self alloc] initWithKey:key andValue:value];
}

- (BOOL)isEqual:(AYPair *)object{
    if (object == self) {
        return YES;
    }
    if (object == nil || ![object isKindOfClass:[AYPair class]]) {
        return NO;
    }
    
    if (![self.key isEqual:object.key]) {
        return NO;
    }
    
    if (![self.value isEqual:object.value]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash{
    NSUInteger result = [self.key hash];
    result = 31 * result + [self.value hash];
    return result;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@<%p>:\n{\n   key: %@\n value: %@\n}", NSStringFromClass([self class]), self, self.key, self.value];
}
@end

AYPair *AYPairMake(id key, id value){
    return [AYPair key:key value:value];
}
