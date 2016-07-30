//
//  AYQueryAction.m
//  Pods
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYQueryAction.h"

@implementation AYQueryAction

+ (instancetype)actionWithBlock:(id)block{
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(id)block{
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (AYTuple *)execute:(AYTuple *)tuple{
    return self.nextAction ? [self.nextAction execute:tuple] : tuple;
}

- (void)setNextAction:(__kindof AYQueryAction *)nextAction{
    if (self.nextAction) {
        self.nextAction.nextAction = nextAction;
    }else{
        _nextAction = nextAction;
    }
}
- (AYQueryAction *)lastAction{
    return self.nextAction ? self.nextAction.nextAction : self;
}
@end
