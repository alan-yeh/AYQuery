# AYQuery

[![CI Status](http://img.shields.io/travis/alan-yeh/AYQuery.svg?style=flat)](https://travis-ci.org/alan-yeh/AYQuery)
[![Version](https://img.shields.io/cocoapods/v/AYQuery.svg?style=flat)](http://cocoapods.org/pods/AYQuery)
[![License](https://img.shields.io/cocoapods/l/AYQuery.svg?style=flat)](http://cocoapods.org/pods/AYQuery)
[![Platform](https://img.shields.io/cocoapods/p/AYQuery.svg?style=flat)](http://cocoapods.org/pods/AYQuery)

## 引用
　　使用[CocoaPods](http://cocoapods.org)可以很方便地引入AYQuery。Podfile添加AYQuery的依赖。

```ruby
pod "AYQuery"
```

## 简介
　　AYQuery是用于处理集合的框架，能提供比较全面的集合处理功能。Objective-C没有提供语法树分析、匿名类、类型推断等功能，所以感觉AYQuery在使用的过程中，虽然能提供一定的便捷性，但仍无法达到像[linq](https://msdn.microsoft.com/zh-cn/library/bb397676.aspx)这样的使用体验。

　　当前AYQuery框架提供了链式调用等特性，但是没有实现延迟计算，将来找机会看看能不能实现，并提供更多api。

　　当前，AYQuery的功能分为以下类别

* Each 遍历
* Filter 筛选与投影
* Range 分区与排序
* Operation 操作
* Convert 转换类型

### Each 遍历
　　AYQuery可以使用一下遍历方法：

```objective-c
AYQueryable *data = @[@1, @3, @9, @0, @9, @-4, @55].query;

// 传统遍历
for (NSUInteger i = 0, count = data.count; i < count; i ++){
	NSLog(@"%@", data[i]);
}

// each 正向遍历
data.each(^(id item){
	NSLog(@"%@", item);
});

// reserseEach 反向遍历
data.reserseEach(^(id item){
	NSLog(@"%@", item);
});

```

### Select 筛选
　　Select分类主要用于筛选集合中符合条件的item，将item投影成新的集合。

| Method | Usage | Return |
| --- | --- | --- |
| find | 查找满足条件的第一个item | 返回bool值，YES为符合条件，NO为不符合 |
| findAll | 查找满足条件的item | 返回bool值，YES为符合条件，NO为不符合 |
| ofType | 筛选符合类型的item |  |
| exclude | 排除两个集合的交集 | NONE |
| intersect | 取两个集合的交集 | NONE |
| select | 在每一个item上执行操作并返回一个结果，将结果组成集合 | 返回新类型的item |
| selectMany | 在每一个item上执行操作并返回一个结果集合，将结果集合组成一个集合 | 返回新类型的item |
| groupBy | 按条件分组；分组后的集合item类型是AYPair，key为分组Key，value为分组item集合 | 返回分组条件 |

```objective-c
//数据准备
NSArray *data = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
NSArray<Student *> *stu = ....

//取第一个姓孙的学生
Student *student = stu.query.find(^BOOL(Student *stu){
    return [stu.name hasSuffix:@"孙"];
});

//筛选所有姓孙的学生
NSArray<Student *> *sunStu = stu.query.findAll(^BOOL(Student *stu){
    return [stu.name hasSuffix:@"孙"];
}).toArray();

//筛选集合里的指定类型的item
NSArray *typedArray = [@[@1, @5, @9, @3, AYPairMake(@"key1", @"value1"), AYPairMake(@"key2", @"value2"), @"aa"].query.ofType([NSNumber class]).toArray();
XCTAsset([@[@1, @5, @9, @3] isEqualToArray:typedArray]);

//移除两个集合的交集
NSArray *exceptedArray = data.query.exclude(@[@55, @0, @3]).toArray();
isEquals = [exceptedArray isEqualToArray:@[@1, @9, @9, @-4]];
XCTAssert(isEquals);

//取两个集合的交集
NSArray *intersectedArray = data.query.intersect(@[@55, @0, @3, @808]).toArray();
isEquals = [intersectedArray isEqualToArray:@[@3, @0, @55]];
XCTAssert(isEquals);

//选择所有学生的姓名
NSArray<NSString *> *stuNames = stu.query.select(^(Student *stu){
    return stu.name;
}).toArray();
    
//将Json数组转成学生
NSArray<NSDictionary<String *, id> *> *jsonData = .....;
NSArray<Student *> *stus = jsonData.query.select(^(NSDictionary *dic){
    return [[Student alloc] initWithAttributes:dic];
}).toArray();
    
//按姓氏将学生分组
NSDictionary<String, NSArray<Student *> *> *stu.query.gorupBy(^(Student *stu){
    return [stu.name substringWithRange:NSMakeRange(0, 1)];
}).toDictionary(nil);
    
```

### Range item分区
　　Range分类主要提供item的分区类功能

| Method | Usage | Return |
| ------ | ----- | ------ |
| count | 当前集合中，剩余item数量 | NONE |
| skip | 跳过前N个item，选择之后的item | NONE |
| skipWhile | 一直跳过item，直接item满足条件 | BOOL, 当第一次返回YES时，参数Block将不再调用 |
| take | 取N个item | NONE |
| takeWhile | 一直item，直到满足条件，跳过剩余的item | BOOL, 当第一次返回YES时，参数Block将不再调用 |
| rangeOf | 跳过前几个item，取N个item | NONE |
| distinct | 去除重复项 | NONE |
| orderBy | 排序 | NSComparisonResult |
| reverse | 反序 | NONE |
| faltten | 扁平化 |  |
| include | 合并两个集合 |  |

```objective-c
NSArray *data = @[@1, @3, @9, @0, @9, @-4, @55];
	
//跳过前3个item
NSArray *skippedArray = data.query.skip(3).toArray(); // @[@0, @9, @-4, @55]
	
//跳过item, 知道item >= 5
NSArray *skippdWhileArray = data.query.skipWhile(^BOOL(NSNumber *e){
    return e.intValue >= 5;
}).toArray(); // @[@5, @0, @9, @-4, @55]
	
//取前5个item
NSArray *takedArray = data.query.take(5).toArray(); // @[@0, @1, @2, @3, @4]
NSArray *takedWhileArray = data.query.takeWhile(^BOOL(NSNumber *e){
    return e.intValue >= 5;
}).toArray(); // @[@0, @1, @2, @3, @4]
	
//跳过3个，取5个
NSArray *rangedArray = data.query.rangeOf(3, 5).toArray();//@[@1, @3, @9, @0, @9]

//去重
NSArray *distincedArray = data.query.distinct().array();
XCTAssert(distincedArray.count == 6);


//排序
NSArray *orderedArray = data.query.orderBy(^(id item1, id item2){
    return [item1 compare:item2];
}).array();
BOOL isOrdered = [orderedArray isEqualToArray:@[@-4, @0, @1, @3, @9, @9, @55]];
XCTAssert(isOrdered);


//倒序
NSArray *reversedArray = data.query.reverse().array();
isOrdered = [reversedArray isEqualToArray:@[@55, @-4, @9, @0, @9, @3, @1]];
XCTAssert(isOrdered);

//扁平化, 将集合里的集合扁平成一个集合
NSArray *flattenedArray = @[@1, @5, @[@9, @3], @{@"key1": @"value1", @"key2", @"value2"}, @"aa"].query.flatten().toArray();
XCTAsset([@[@1, @5, @9, @3, AYPairMake(@"key1", @"value1"), AYPairMake(@"key2", @"value2"), @"aa"] isEquarlToArray: flattenedArray]);

//合并两个集合
NSArray *includedArray = data.query.include(@[@450, @888, @808]).toArray();
isEquals = [includedArray isEqualToArray:@[@1, @3, @9, @0, @9, @-4, @55, @450, @888, @808]];
XCTAssert(isEquals);
```

### Operate item操作
　　Operate用于操作item

| Method | Usage | Return |
| --- | --- | --- |
| first | 取第一个item | NONE |
| firstOrDefault | 取第一个item，如果为空，则返回默认值 |  |
| last | 取最后一个item | NONE |
| lastOrDefault | 取最后一个item，如果为空，则返回默认值 |  |
| get | 取第N个item，如果N为负数，则从后开始取值 | NONE |
| getOrDefault | 取第N个item，如果N为负数，则从后开始取值，如果为空，则返回默认值 |  |
| max | 选取最大的item | NSComparisonResult |
| min | 取选最小的item | NSComparisonResult |
| contains | 是否包含 | NONE |
| any | 判断是否有item满足条件 | BOOL |
| all | 判断是否所有item满足条件 |  |
| join | 将所有item连接起来 | NONE |

```objective-c
NSArray *data = @[@1, @3, @9, @0, @9, @-4, @55];

//取第一个item
id first_item = data.query.first(); // @1
id first_or_default_item = data.query.firstOrDefault(@6); //@1, 如果data为空数组，则返回@6
id get_first_item = data.query.get(0); // @1
id get_first_or_default_item = data.query.getOrDefault(0, @6); //@1, 如果data为空数组，则返回@6

//取最后一个item
id last_item = data.query.last(); // @55
id last_or_default_item = data.query.lastOrDefault(@6); //@55, 如果data为空数组，则返回@6
id get_last_item = data.query.get(-1); // @55
id get_last_item2 = data.query.get(array.count - 1); // @55

//取最大值
id max = data.query.max(^(id item1, id item2){
    return [item2 compare:item1];
});
XCTAssert([max isEqual:@55]);

//取最小值
id min = data.query.min(^(id item1, id item2){
    return [item2 compare:item1];
});
XCTAssert([min isEqual:@-4]);

//是否包含item
BOOL isContains = data.query.contains(@66);
XCTAssert(!isContains);

//是否有item满足条件
BOOL isAny = data.query.any(^BOOL(id item){
    return [item integerValue] > 66;
});
XCTAssert(!isAny);

//是否所有item都满足条件
BOOL isAll = data.query.all(^BOOL(id item){
    return [item integerValue] > 66;
});
XCTAssert(!isAll);

//连接
NSString *joinString = data.query.join(@",");
BOOL isEquals = [@"1,3,9,0,9,-4,55" isEqualToString:joinString];
XCTAssert(isEquals);

```

### Convert 类型转换
　　Convert分类用于将AYQuery里的item转换成NSArray、NSDictionary、NSSet。

Method | Usage | Return |
-------|-------|--------|
toDictionary | 将集合转换成NSDictionary | 返回AYPair |
toArray | 将集合转换成NSArray | NONE |
toSet | 将集合转换成NSSet | NONE |

```objective-c
	NSArray<Student *> *stus = ....
	//建立name, Student的印射关系
	NSDictionary<NSString *, Student *> *nameMap = stus.query.toDictionary(^(Student *stu){
	    return AYPairMake(stu.name, stu);
	});
	
	//如果集合里面的所有item都是AYPair类型，可以直接转换成NSDictionary。
	NSDictionary *result = @{@"1": @1, @"2": @2, @"3": @3, @"4": @4}.query.findAll(^(AYPair *item){
	    return [item.value integerValue] > 2;
	}).toDictionary(nil);
	
	NSLog(@"%@", result); // @{@"3": @3, @"4": @4}
	
    //toArray和toSet的用法上面已经演示很多了，就不再写例子了
```

### AYOptional
　　由于AYQuery采用的是链式调用语法，这种语法有一个比较大的缺陷就是当对象为空时，会出现BAD_ACCESS错误。

```objective-c
	NSArray<Student *> *stus = nil;
	stus.query.findAll(...); //BAD_ACCESS
```

　　为了提高应用的稳定性，可以采用以下两种办法。

```objective-c
	//先判断是否为空，再进行操作
	if (stus.count){
	    stus.query.findAll(...);
	}

	//使用AYOptional进行操作
	AYOptional(NSArray, stus).findAll(...);
```
> AYOptional在AYCategory包中


## License

AYQuery is available under the MIT license. See the LICENSE file for more info.


