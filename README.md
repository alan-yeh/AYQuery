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
* Select 筛选与投影
* Range 元素分区
* Operation 元素操作
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
data.each(^(id item){
	NSLog(@"%@", item);
});

```

### Select 筛选
　　Select分类主要用于筛选集合中符合条件的元素，将元素投影成新的集合。

| Method | Usage | Return |
| --- | --- | --- |
| findAll | 查找满足条件的item | 返回bool值，YES为符合条件，NO为不符合 |
| find | 查找满足条件的第一个item | 返回bool值，YES为符合条件，NO为不符合 |
| select | 在每一个item上执行操作并返回一个结果集 | 返回新类型的item |
| groupBy | 按条件分组；分组后的集合item类型是AYPair，key为分组Key，value为分组item集合 | 返回分组条件 |

```objective-c
	//数据准备
	NSArray<Student *> *stu = ....
	
   /* where *********************************/
	//筛选姓孙的学生
	NSArray<Student *> *sunStu = stu.query.where(^BOOL(Student *stu){
        return [stu.name hasSuffix:@"孙"];
    }).array();
    
    /* select *********************************/
    //选择所有学生的姓名
    NSArray<NSString *> *stuNames = stu.query.select(^(Student *stu){
    	return stu.name;
    }).array();
    
    //将Json数组转成学生
    NSArray<NSDictionary<String *, id> *> *jsonData = .....;
    NSArray<Student *> *stus = jsonData.query.select(^(NSDictionary *dic){
       return [[Student alloc] initWithAttributes:dic];
    }).array();
    
```

### Range 元素分区
　　Range分类主要提供元素的分区类功能

Method | Usage | Return |
-------|-------|--------|
skip | 跳过前几个元素，选择之后的元素 | NONE |
skipWhile | 一直跳过元素，直接元素满足条件 | BOOL, 当第一次返回YES时，参数Block将不再调用 |
take | 取多少个元素 | NONE |
takeWhile | 一直取元素，直到满足条件，跳过剩余的元素 | BOOL, 当第一次返回YES时，参数Block将不再调用 |
rangeOf | 跳过前几个元素，取几个元素 | NONE |
count | 当前Stream中，剩余多少个元素 | NONE |

```objective-c
	NSArray *data = @[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9];
	
	//跳过前5个元素
	NSArray *array0 = data.query.skip(5).array(); // @[@5, @6, @7, @8, @9]
	
	//跳过小于5的元素
	NSArray *array1 = data.query.skipWhile(^BOOL(NSNumber *e){
	    return e.intValue >= 5;
	}).array(); // @[@5, @6, @7, @8, @9]
	
	//取前5个元素
	NSArray *array2 = data.query.take(5).array(); // @[@0, @1, @2, @3, @4]
	NSArray *array3 = data.query.takeWhile(^BOOL(NSNumber *e){
	    return e.intValue >= 5;
	}).array(); // @[@0, @1, @2, @3, @4]
	
	//跳过3个，取5个
	NSArray *array4 = data.query.rangeOf(3, 5).array();//@[@3, @4, @5, @6, @7]
```

### Operate 元素操作
　　Operate用于操作元素

| Method | Usage | Return |
| --- | --- | --- |
| first | 取第一个item | NONE |
| last | 取最后一个item | NONE |
| get | 取第N个item，如果N为负数，则从后开始取值 | NONE |
| max | 选取最大的元素 | NSComparisonResult |
| min | 取选最小的元素 | NSComparisonResult |
| contains | 是否包含 | NONE |
| any | 判断是否有item满足条件 | BOOL |
| orderBy | 排序 | NSComparisonResult  |
| distinct | 去除重复项 | NONE |
| reverse | 反序 | NONE |
| join | 将所有item连接起来 | NONE |
| minus | 移除集合里的元素 | NONE |
| add | 添加集合里的元素 | NONE  |

```objective-c
NSArray *data = @[@1, @3, @9, @0, @9, @-4, @55];

//取第一个item
id first_item = data.query.first; // @1
id get_first_item = data.query.get(0); // @1

//取最后一个item
id last_item = data.query.last; // @55
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

//是否保含元素
BOOL isContains = data.query.contains(@66);
XCTAssert(!isContains);

//是否有元素满足条件
BOOL isAny = data.query.any(^BOOL(id item){
    return [item integerValue] > 66;
});
XCTAssert(!isAny);

//排序
NSArray *orderedArray = data.query.orderBy(^(id item1, id item2){
    return [item1 compare:item2];
}).array();
BOOL isOrdered = [orderedArray isEqualToArray:@[@-4, @0, @1, @3, @9, @9, @55]];
XCTAssert(isOrdered);

//去重
NSArray *distincedArray = data.query.distinct().array();
XCTAssert(distincedArray.count == 6);

//倒序
NSArray *reversedArray = data.query.reverse().array();
isOrdered = [reversedArray isEqualToArray:@[@55, @-4, @9, @0, @9, @3, @1]];
XCTAssert(isOrdered);

//连接
NSString *joinString = data.query.join(@"+");
BOOL isEquals = [@"1+3+9+0+9+-4+55" isEqualToString:joinString];
XCTAssert(isEquals);

//移除items
NSArray *minusedArray = data.query.minus(@[@55, @0, @3]).array();
isEquals = [minusedArray isEqualToArray:@[@1, @9, @9, @-4]];
XCTAssert(isEquals);

//添加items 
NSArray *addedArray = data.query.add(@[@920, @658]).array();
isEquals = [addedArray isEqualToArray:@[@1, @3, @9, @0, @9, @-4, @55, @920, @658]];
XCTAssert(isEquals);

//按姓名排序
NSArray<Student *> *orderedStu = stus.query.orderBy(^NSComparisonResult(Student stu1, Student stu2){
	return [obj1.name compare:obj2.name];
}).array();

```

### Convert 类型转换
　　Convert分类用于将AYQuery里的元素转换成NSArray、NSDictionary、NSSet。

Method | Usage | Return |
-------|-------|--------|
dictionary | 将集合转换成NSDictionary | 返回AYPair |
array | 将集合转换成NSArray | NONE |
set | 将集合转换成NSSet | NONE |

```objective-c
	NSArray<Student *> *stus = ....
	//建立name, Student的印射关系
	NSDictionary<NSString *, Student *> *nameMap = stus.query.dictionary(^(Student *stu){
	    return AYPairMake(stu.name, stu);
	});
    //array和set的用法上面已经演示很多了，就不再写例子了
```

### AYQueryMake
　　由于AYQuery采用的是链式调用语法，这种语法有一个比较大的缺陷就是当其中一个的返回值为空时，会出现BAD_ACCESS错误。

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

	//使用AYQueryMake来获取AYQueryable对象然后进行操作
	AYQueryMake(stus).findAll(...);
```


## License

AYQuery is available under the MIT license. See the LICENSE file for more info.


