//
//  AYQuerySelectAction.m
//  Pods
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYQuerySelectAction.h"
#import "AYTuple.h"

@implementation AYQuerySelectAction
@dynamic block;

- (AYTuple *)execute:(AYTuple *)tuple{
    id result = self.block(tuple.value);
    if (result == nil) {
        return result;
    }else{
        return [self.nextAction execute:[result isKindOfClass:[AYTuple class]] ? result : AYTupleArray(result)];
    }
}
@end
