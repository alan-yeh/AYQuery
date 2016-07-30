//
//  AYQueryWhereAction.m
//  Pods
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYQueryWhereAction.h"

@implementation AYQueryWhereAction
@dynamic block;

- (AYTuple *)execute:(AYTuple *)tuple{
    return self.block(tuple.value) ? [self.nextAction execute:tuple] : nil;
}
@end
