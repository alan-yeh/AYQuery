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
@property (readonly) void(^each)(id);/**< 遍历 */
@property (readonly) void(^reverseEach)(id);/**< 反向遍历 */
@end

// 筛选与投影
@interface AYQueryable (Filter)
@property (readonly) _Nullable id (^find)(BOOL(^)(id));/**< 查找满足条件的第一个item */
@property (readonly) AYQueryable *(^findAll)(BOOL(^)(id));/**< 查找满足条件的所有item */
@property (readonly) AYQueryable *(^ofType)(Class);/**< 筛选集合里的指定类型的item */
@property (readonly) AYQueryable *(^exclude)(id);/**< 移除两个集合的交集, 可以是id类型，也可以是id<AYQuery>类型 */
@property (readonly) AYQueryable *(^intersect)(id<AYQuery>);/**< 两个集合的交集 */
@property (readonly) AYQueryable *(^select)(id(^)(id));/**< 在每一个item上执行操作并返回一个结果集 */
@property (readonly) AYQueryable *(^selectMany)(id(^)(id));/**< 在每一个item上执行操作并返回一个结果集, 并结果集扁平化（相当于在select().faltten()） */
@property (readonly) AYQueryable *(^groupBy)(id(^)(id));/**< 按条件分组 */
@end

// 分区与排序
@interface AYQueryable (Range)
@property (readonly) NSUInteger count;
@property (readonly) AYQueryable *(^skip)(NSUInteger);/**< 跳过N个item */
@property (readonly) AYQueryable *(^skipWhile)(BOOL(^)(id));/**< 跳过item，直至满足条件 */
@property (readonly) AYQueryable *(^take)(NSUInteger);/**< 取N个item */
@property (readonly) AYQueryable *(^takeWhile)(BOOL(^)(id));/**< 取N个item，直至满足条件 */
@property (readonly) AYQueryable *(^rangeOf)(NSUInteger, NSUInteger);/**< 取范围内的item */
@property (readonly) AYQueryable *(^distinct)();/**< 去重 */
@property (readonly) AYQueryable *(^orderBy)(NSComparisonResult(^)(id, id));/**< 排序 */
@property (readonly) AYQueryable *(^reverse)();/**< 反序 */
@property (readonly) AYQueryable *(^flatten)();/**< 扁平化 */
@property (readonly) AYQueryable *(^include)(id);/**< 合并两个集合，或者添加一个元素, 可以是id类型，也可以是id<AYQuery>类型 */
@end

// 操作
@interface AYQueryable (Operation)
@property (readonly) _Nullable id (^first)();/**< 第一个item，如果query没有item则返回nil */
@property (readonly) id (^firstOrDefault)(id);/**< 第一个item，如果query没有item则返回default */
@property (readonly) _Nullable id (^last)();/**< 最后一个item，如果query没有item则返回nil */
@property (readonly) id (^lastOrDefault)(id);/**< 最后一个item，如果query没有item则返回default */
@property (readonly) _Nullable id (^get)(NSUInteger);/**< 取第N个item，如果N为负数，则从后开始取值，如果超界了，则返回nil */
@property (readonly) id (^getOrDefault)(NSUInteger, id);/**< 取第N个item，如果N为负数，则从后开始取值，如果nil，则返回default */
@property (readonly) _Nullable id (^max)(NSComparisonResult(^)(id, id));/**< 取最大值 */
@property (readonly) _Nullable id (^min)(NSComparisonResult(^)(id, id));/**< 取最小值 */
@property (readonly) BOOL (^contains)(id);/**< 是否包含某个item，使用isEquals来判断 */
@property (readonly) BOOL (^any)(BOOL(^)(id));/**< 判断是否有item满足条件 */
@property (readonly) BOOL (^all)(BOOL(^)(id));/**< 判断是所有item满足条件 */
@property (readonly) NSString *(^join)(NSString *seperator);/**< 将所有item连接起来 */
@end

@class AYTuple;
// 转化为NSDictionary、NSArray、NSSet
@interface AYQueryable (Convert)
@property (readonly) NSDictionary *(^toDictionary)(AYPair *(^_Nullable)(id));/**< 转换成dictionary */
@property (readonly) NSArray *(^toArray)();/**< 转换成array */
@property (readonly) NSSet *(^toSet)();/**< 转换成set */
@end

NS_ASSUME_NONNULL_END
