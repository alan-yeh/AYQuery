//
//  AYPair.h
//  AYQuery
//
//  Created by Alan Yeh on 2016/11/9.
//
//

#import <Foundation/Foundation.h>

@class AYPair;
FOUNDATION_EXPORT AYPair *AYPairMake(id key, id value);

@interface AYPair : NSObject
@property id key;
@property id value;

+ (instancetype)key:(id)key value:(id)value;
+ (instancetype)pairWithKey:(id)key andValue:(id)value;
- (instancetype)initWithKey:(id)key andValue:(id)value;
@end
