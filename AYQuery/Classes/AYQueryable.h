//
//  AYQueryable.h
//  AYQuery
//
//  Created by Alan Yeh on 16/7/20.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AYQuery;
@class AYPair;

@interface AYQueryable : NSObject<NSFastEnumeration>
- (instancetype)init __attribute__((unavailable("不允许直接实例化")));
+ (instancetype)new __attribute__((unavailable("不允许直接实例化")));

- (instancetype)initWithDatasource:(NSArray *)datasource;

/** 如果是负数，则返回倒数item，如query[-1]就是列表最后一个item，如果超界了，则返回nil */
- (_Nullable id)objectAtIndexedSubscript:(NSInteger)idx;
@property (readonly) void(^each)(id item);/**< 遍历 */
@property (readonly) void(^reverseEach)(id item);/**< 反向遍历 */
@end

// 筛选与投影
@interface AYQueryable (Filter)
@property (readonly) _Nullable id (^find)(BOOL(^)(id item));/**< 查找满足条件的第一个item */
@property (readonly) AYQueryable *(^findAll)(BOOL(^)(id item));/**< 查找满足条件的所有item */
@property (readonly) AYQueryable *(^ofType)(Class type);/**< 筛选集合里的指定类型的item */
@property (readonly) AYQueryable *(^exclude)(id collection);/**< 移除两个集合的交集, 可以是id类型，也可以是id<AYQuery>类型 */
@property (readonly) AYQueryable *(^intersect)(id<AYQuery> collection);/**< 两个集合的交集 */
@property (readonly) AYQueryable *(^select)(id(^)(id item));/**< 在每一个item上执行操作并返回一个结果集 */
@property (readonly) AYQueryable *(^selectMany)(id(^)(id item));/**< 在每一个item上执行操作并返回一个结果集, 并结果集扁平化（相当于在select().faltten()） */
@property (readonly) AYQueryable *(^groupBy)(id(^)(id item));/**< 按条件分组 */
@end

// 分区与排序
@interface AYQueryable (Range)
@property (readonly) NSUInteger count;
@property (readonly) AYQueryable *(^skip)(NSUInteger count);/**< 跳过N个item */
@property (readonly) AYQueryable *(^skipWhile)(BOOL(^)(id item));/**< 跳过item，直至满足条件 */
@property (readonly) AYQueryable *(^take)(NSUInteger count);/**< 取N个item */
@property (readonly) AYQueryable *(^takeWhile)(BOOL(^)(id item));/**< 取N个item，直至满足条件 */
@property (readonly) AYQueryable *(^rangeOf)(NSUInteger start, NSUInteger end);/**< 取范围内的item */
@property (readonly) AYQueryable *(^distinct)(void);/**< 去重 */
@property (readonly) AYQueryable *(^orderBy)(NSComparisonResult(^)(id first, id second));/**< 排序 */
@property (readonly) AYQueryable *(^reverse)(void);/**< 反序 */
@property (readonly) AYQueryable *(^flatten)(void);/**< 扁平化 */
@property (readonly) AYQueryable *(^include)(id collection);/**< 合并两个集合，或者添加一个元素, 可以是id类型，也可以是id<AYQuery>类型 */
@end

// 操作
@interface AYQueryable (Operation)
@property (readonly) _Nullable id (^first)(void);/**< 第一个item，如果query没有item则返回nil */
@property (readonly) id (^firstOrDefault)(id defaultValue);/**< 第一个item，如果query没有item则返回default */
@property (readonly) _Nullable id (^last)(void);/**< 最后一个item，如果query没有item则返回nil */
@property (readonly) id (^lastOrDefault)(id defaultValue);/**< 最后一个item，如果query没有item则返回default */
@property (readonly) _Nullable id (^get)(NSUInteger index);/**< 取第N个item，如果N为负数，则从后开始取值，如果超界了，则返回nil */
@property (readonly) id (^getOrDefault)(NSUInteger index, id defaultValue);/**< 取第N个item，如果N为负数，则从后开始取值，如果nil，则返回default */
@property (readonly) _Nullable id (^max)(NSComparisonResult(^)(id first, id second));/**< 取最大值 */
@property (readonly) _Nullable id (^min)(NSComparisonResult(^)(id first, id second));/**< 取最小值 */
@property (readonly) BOOL (^contains)(id item);/**< 是否包含某个item，使用isEquals来判断 */
@property (readonly) BOOL (^any)(BOOL(^)(id item));/**< 判断是否有item满足条件 */
@property (readonly) BOOL (^all)(BOOL(^)(id item));/**< 判断是所有item满足条件 */
@property (readonly) NSString *(^join)(NSString *seperator);/**< 将所有item连接起来 */
@end

@class AYTuple;
// 转化为NSDictionary、NSArray、NSSet
@interface AYQueryable (Convert)
@property (readonly) NSDictionary *(^toDictionary)(AYPair *(^_Nullable)(id item));/**< 转换成dictionary */
@property (readonly) NSArray *(^toArray)(void);/**< 转换成array */
@property (readonly) NSSet *(^toSet)(void);/**< 转换成set */
@end

NS_ASSUME_NONNULL_END
