//
//  AYQueryAction.h
//  Pods
//
//  Created by PoiSon on 16/7/30.
//
//

#import <Foundation/Foundation.h>
#import <AYQuery/AYTuple.h>

NS_ASSUME_NONNULL_BEGIN
@interface AYQueryAction : NSObject
@property (nonatomic, retain) __kindof AYQueryAction *nextAction;
@property (readonly) __kindof AYQueryAction *lastAction;

@property (nonatomic, readonly) id block;

+ (instancetype)actionWithBlock:(id)block;
- (instancetype)initWithBlock:(id)block;

- (nullable AYTuple *)execute:(AYTuple *)tuple;
@end
NS_ASSUME_NONNULL_END
