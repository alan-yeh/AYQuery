//
//  AYQueryable.h
//  AYQuery
//
//  Created by PoiSon on 16/7/20.
//
//

#import <Foundation/Foundation.h>

@class AYTuple;

@interface AYQueryable : NSObject<NSFastEnumeration>
+ (instancetype)nilQuery;
- (instancetype)init __attribute__((unavailable("不允许直接实例化")));
+ (instancetype)new __attribute__((unavailable("不允许直接实例化")));

- (instancetype)initWithDatasource:(NSArray<AYTuple *> *)datasource;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)foreach:(void (^)(id e, NSUInteger idx, BOOL *stop))foreach;
@end

// 筛选与投影
@interface AYQueryable (Select)
@property (readonly) AYQueryable *(^where)(BOOL(^)(id));
@property (readonly) AYQueryable *(^select)(id(^)(id));
@property (readonly) AYQueryable *(^ofType)(Class);
@property (readonly) AYQueryable *(^groupBy)(id(^)(id));
@end

// 元素分区
@interface AYQueryable (Range)
@property (readonly) NSUInteger count;
@property (readonly) AYQueryable *(^skip)(NSUInteger);
@property (readonly) AYQueryable *(^skipWhile)(BOOL(^)(id));
@property (readonly) AYQueryable *(^take)(NSUInteger);
@property (readonly) AYQueryable *(^takeWhile)(BOOL(^)(id));
@property (readonly) AYQueryable *(^rangeOf)(NSUInteger, NSUInteger);
@end

// 元素操作
@interface AYQueryable (Operation)
@property (readonly) id first;
@property (readonly) id last;
@property (readonly) id (^at)(NSUInteger);
@property (readonly) id (^max)(NSComparisonResult(^)(id, id));
@property (readonly) id (^min)(NSComparisonResult(^)(id, id));
@property (readonly) BOOL (^contains)(id);
@property (readonly) AYQueryable *(^orderBy)(NSComparisonResult(^)(id, id));
@property (readonly) AYQueryable *distinct;
@property (readonly) AYQueryable *reverse;
@end

@class AYTuple;
// 转化为NSDictionary、NSArray、NSSet
@interface AYQueryable (Convert)
@property (readonly) NSDictionary *(^dictionary)(AYTuple *(^)(id));
@property (readonly) NSArray *array;
@property (readonly) NSSet *set;
@end