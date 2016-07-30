//
//  AYTuple.h
//  AYQuery
//
//  Created by PoiSon on 16/7/30.
//
//

#import <Foundation/Foundation.h>
#import <AYQuery/metamacros.h>

//
#define AYTupleArray(...) ([AYTuple tupleWithObjects:@[metamacro_foreach(_ay_object_or_nil,, __VA_ARGS__)]])

#define AYTupleObject(...) \
   ({ \
      metamacro_foreach(_ay_object_decl_assign,, __VA_ARGS__) \
      metamacro_foreach(_ay_object_decl,, __VA_ARGS__) \
      [AYTuple tupleWithObjects:@[metamacro_foreach(_ay_object_value,, __VA_ARGS__)] forKeys:@[metamacro_foreach(_ay_object_key,, __VA_ARGS__)]]; \
   })


#define _ay_unpack_decl_name(INDEX) metamacro_concat(metamacro_concat(_var, __LINE__), INDEX)
#define _ay_object_or_nil(index, arg) (arg) ?: [NSNull null],
#define _ay_object_decl_assign(INDEX, ARG) __strong id ARG;
#define _ay_object_decl(INDEX, ARG) __strong id _ay_unpack_decl_name(INDEX) = ((ARG) ?: [NSNull null]);
#define _ay_object_key(INDEX, ARG) @#ARG,
#define _ay_object_value(INDEX, ARG) _ay_unpack_decl_name(INDEX),

NS_ASSUME_NONNULL_BEGIN
@interface AYTuple : NSObject
@property (readonly, nonnull) id value;

+ (instancetype)tupleWithObjects:(NSArray *)objects;
+ (instancetype)tupleWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;
@end

@interface _ay_tuple_trampoline : NSObject
+ (instancetype)trampoline;
- (void)setObject:(id)obj forKeyedSubscript:(nonnull id<NSCopying>)key;
@end
NS_ASSUME_NONNULL_END