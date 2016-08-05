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
　　AYQuery是用于处理集合的框架。灵感来自于ReactiveCocoa，但是希望能提供更多更全面的集合处理功能，所以简单编写了AYQuery框架。Objective-C没有提供语法树分析、匿名类、类型推断等功能，所以感觉AYQuery在使用的过程中，虽然能提供一定的便捷性，但仍无法达到像[linq](https://msdn.microsoft.com/zh-cn/library/bb397676.aspx)这样的使用体验。

　　当前AYQuery框架提供了延迟计算（部份）、链式调用等特性，但整体还不是特别成熟，性能在将来会再次优化，并提供更多api。

　　当前，AYQuery的功能分为以下类别

* Select 筛选与投影
* Range 元素分区
* Operation 元素操作
* Convert 转换类型

### Select 筛选
　　Select分类主要用于筛选集合中符合条件的元素，将元素投影成新的集合。

Method | Usage | Return |
-------|-------|--------|
where  | 筛选指定条件的元素 | 返回bool值，YES为符合条件，NO为不符合|
select | 将元素投影到新的集合中 | 返回新类型的元素 |
ofType | 筛选集合中的类型符合的元素 | NONE |

```objective-c
	//数据准备
	NSArray<Student *> *stu = ....
	
   /* where *********************************/
	//筛选姓孙的学生
	NSArray<Student *> *sunStu = stu.query.where(^BOOL(Student *stu){
        return [stu.name hasSuffix:@"孙"];
    }).array;
    
    /* select *********************************/
    //选择所有学生的姓名
    NSArray<NSString *> *stuNames = stu.query.select(^(Student *stu){
    	return stu.name;
    }).array;
    
    //将Json数组转成学生
    NSArray<NSDictionary<String *, id> *> *jsonData = .....;
    NSArray<Student *> *stus = jsonData.query.select(^(NSDictionary *dic){
       return [[Student alloc] initWithAttributes:dic];
    }).array;
    
    /* ofType *********************************/
    NSArray *array = @[@"abc", @1, stu, sunStu, @"bbb", @"aac", @65];
    //筛选数组中的字符串
    NSArray<NSString *> *strs = array.query.ofType([NSString class]).array;
```
##### 匿名类与数组
　　为了方便AYQuery的各类操作，我封装了AYTupleObject(匿名类)、AYTupleArray（匿名数组），用于方使select等需要多个返回值的函数。

```objective-c
    NSArray *array = stu.query.select(^(Student *stu){
        //返回匿名类
        return AYTupleObject(Name = stu.name, Age = @(stu.age));
    }).where(^BOOL(id e){
        //这里的e是上次的匿名类，取数据可以使用e[Key]这样的格式取数据
        //返回name是以"孙"开头的元素
        return [e[@"Name"] hasPrefix:@"孙"];
    }).array;
    //以上最后得出来的结果array是NSArray<NSDictionary<NSString *, NSNumber *> *> *类型。
    
    /*********************************************************/
    NSArray *array = stu.query.select(^(Student *stu){
        //返回匿名数组
        return AYTupleArray(stu.name, @(stu.age));
    }).where(^BOOL(id e) {
        //这里的e是上次的匿名数组，取数据可以使用e[index]这样的格式取数据
        //返回第一个元素是以"孙"开头的
        return [e[0] hasPrefix:@"孙"];
    }).array;
    //以上最后得出来的结果array是NSArray<NSArray *> *类型
    
    /*********************************************************/
    NSDictionary<NSString *, Student *> *dic = stus.query.dictionary(^(Student *stu){
        //由于NSDictionary的是Key-Vlaue结构，所以需要返回对应结构的数据。
        return AYTupleObject(Key = stu.name, Value = stu);
    });
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
	NSArray *array0 = data.query.skip(5).array; // @[@5, @6, @7, @8, @9]
	
	//跳过小于5的元素
	NSArray *array1 = data.query.skipWhile(^BOOL(NSNumber *e){
	    return e.intValue >= 5;
	}).array; // @[@5, @6, @7, @8, @9]
	
	//取前5个元素
	NSArray *array2 = data.query.take(5).array; // @[@0, @1, @2, @3, @4]
	NSArray *array3 = data.query.takeWhile(^BOOL(NSNumber *e){
	    return e.intValue >= 5;
	}).array; // @[@0, @1, @2, @3, @4]
	
	//跳过3个，取5个
	NSArray *array4 = data.query.rangeOf(3, 5).array;//@[@3, @4, @5, @6, @7]
```

### Operate 元素操作
　　Operate用于操作元素

Method | Usage | Return |
-------|-------|--------|
first | 取第一个元素 | NONE |
last | 取最后一个元素 | NONE |
at | 取元素 | NONE |
max | 选取最大的元素 | NSComparisonResult |
min | 取选最小的元素 | NSComparisonResult |
contains | 是否包含 | NONE |
orderBy | 排序 | 返回排序结果 |
distinct | 去除重复项 | NONE |
foreach | 遍历 | NONE |

```objective-c
	//按姓名排序
	NSArray<Student *> *orderedStu = stus.query.orderBy:(^NSComparisonResult(Student stu1, Student stu2){
	    return [obj1.name compare:obj2.name];
	}).array;
    
    NSArray *array = @[@1, @5, @9, @5, @2, @4];
    NSArray *array1 = array.query.distinct.array; // @[@1, @5, @9, @2, @4];
```

### Convert 类型转换
　　Convert分类用于将AYQuery里的元素转换成NSArray、NSDictionary、NSSet。

Method | Usage | Return |
-------|-------|--------|
dictionary | 将集合转换成NSDictionary | 返回AYTupleArray(...) |
array | 将集合转换成NSArray | NONE |
set | 将集合转换成NSSet | NONE |

```objective-c
	NSArray<Student *> *stus = ....
	//建立name, Student的印射关系
	NSDictionary<NSString *, Student *> *nameMap = stus.query.dictionary(^(Student *stu){
	    return AYTupleObject(Key = stu.name, Value = stu);
	});
    //array和set的用法上面已经演示很多了，就不再写例子了
```

### AYQueryMake
　　由于AYQuery采用的是链式调用语法，这种语法有一个比较大的缺陷就是当其中一个的返回值为空时，会出现BAD_ACCESS错误。

```objective-c
	NSArray<Student *> *stus = nil;
	stus.query.where(...); //BAD_ACCESS
```

　　为了提高应用的稳定性，可以采用以下两种办法。

```objective-c
	//先判断是否为空，再进行操作
	if (stus.count){
	    stus.query.where(...);
	}

	//使用AYQueryMake来获取AYQueryable对象然后进行操作
	AYQueryMake(stus).where(...);
```


## License

AYQuery is available under the MIT license. See the LICENSE file for more info.
