//
//  AYQueryTests.m
//  AYQuery
//
//  Created by Alan Yeh on 16/7/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AYQuery/AYQuery.h>
#import <AYCategory/AYCategory.h>

#import "Student.h"
#import "Teacher.h"

@interface AYQueryArrayTests : XCTestCase
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation AYQueryArrayTests


- (void)setUp {
    [super setUp];
    self.data = [NSMutableArray array];
    for (int i = 1; i < 1000; i ++) {
        if (i % 2 == 0) {
            Student *newStu = [Student new];
            newStu.name = [NSString stringWithFormat:@"张%@", @(i)];
            newStu.age = i;
            [self.data addObject:newStu];
        }
        if (i % 3 == 0) {
            Teacher *newTea = [Teacher new];
            newTea.name = [NSString stringWithFormat:@"王%@", @(i)];
            newTea.age = 15 + i;
            [self.data addObject:newTea];
        }
        
        if (i % 5 == 0) {
            Student *newStu = [Student new];
            newStu.name = [NSString stringWithFormat:@"吴%@", @(i)];
            newStu.age = i;
            [self.data addObject:newStu];
        }
        
        if (i % 7 == 0) {
            Student *newStu = [Student new];
            newStu.name = [NSString stringWithFormat:@"孙%@", @(i)];
            newStu.age = i;
            [self.data addObject:newStu];
        }
    }
}

- (void)testOptional{
    NSArray *array = nil;
    NSSet *set = AYOptional(NSArray, array).query.set();
    XCTAssert(set != nil && set.count < 1 && [set isKindOfClass:[NSSet class]]);
}

- (void)testFind{
    NSArray *sunStu = self.data.query.findAll(^BOOL(Student *stu){
        return [stu.name hasPrefix:@"孙"];
    }).array();
    
    XCTAssert(sunStu.count == 142);
    
    for (Student *stu in sunStu) {
        XCTAssert([stu.name hasPrefix:@"孙"]);
    }
    
    Student *stu = self.data.query.find(^BOOL(Student *item){
        return [item.name hasPrefix:@"张"];
    });
    
    XCTAssert([stu isKindOfClass:[Student class]]);
    XCTAssert([stu.name isEqualToString:@"张2"]);
    
    
}

- (void)testSelect{
    NSArray *names = self.data.query.select(^(Student *stu){
        return stu.name;
    }).array();
    
    XCTAssert(names.count == self.data.count);
    
    for (NSString *name in names) {
        XCTAssert([name isKindOfClass:[NSString class]]);
    }
}


- (void)testGroupBy{
    NSArray *groups = self.data.query.groupBy(^(Student *stu){
        return [stu.name substringWithRange:NSMakeRange(0, 1)];
    }).array();
    
    XCTAssert(groups.count == 4);
    
    NSSet *groupKeys = groups.query.select(^(AYPair *group){
        return group.key;
    }).set();
    
    BOOL isEquals = [groupKeys isEqualToSet:[NSSet setWithObjects:@"张", @"王", @"吴", @"孙", nil]];
    XCTAssert(isEquals);
}

- (void)testRange{
    //跳过3个item
    NSArray *skips = self.data.query.skip(3).array();
    XCTAssert([[skips[0] name] isEqualToString:[self.data[3] name]]);
    XCTAssert(skips.count == self.data.count - 3);
    
    //取10个item
    NSArray *takes = self.data.query.take(10).array();
    XCTAssert(takes.count == 10);
    
    //取范围
    NSArray *ranges = self.data.query.rangeOf(3, 3).array();
    XCTAssert(ranges.count == 3);
}

- (void)testEach{
    NSArray *data = @[@1, @3, @9, @0, @9, @-4, @55];
    
    NSMutableString *eachString = [NSMutableString string];
    data.query.each(^(id item){
        [eachString appendFormat:@"%@", item];
    });
    XCTAssert([eachString isEqualToString:@"13909-455"]);
    
    NSMutableString *reverseEach = [NSMutableString string];
    data.query.reverseEach(^(id item){
        [reverseEach appendFormat:@"%@", item];
    });
    XCTAssert([reverseEach isEqualToString:@"55-490931"]);
}

- (void)testOperation{
    NSArray *data = @[@1, @3, @9, @0, @9, @-4, @55];
    
    id first = data.query.first;
    XCTAssert([first isEqual:@1]);
    
    id last = data.query.last;
    XCTAssert([last isEqual:@55]);
    
    id get_first = data.query.get(0);
    XCTAssert([get_first isEqual:@1]);
    
    id get_last = data.query.get(-1);
    XCTAssert([get_last isEqual:@55]);
    
    id max = data.query.max(^(id item1, id item2){
        return [item2 compare:item1];
    });
    XCTAssert([max isEqual:@55]);
    
    id min = data.query.min(^(id item1, id item2){
        return [item2 compare:item1];
    });
    XCTAssert([min isEqual:@-4]);
    
    BOOL isContains = data.query.contains(@66);
    XCTAssert(!isContains);
    
    isContains = data.query.contains(@0);
    XCTAssert(isContains);
    
    BOOL isAny = data.query.any(^BOOL(id item){
        return [item integerValue] > 66;
    });
    XCTAssert(!isAny);
    
    isAny = data.query.any(^BOOL(id item){
        return [item integerValue] <0;
    });
    XCTAssert(isAny);
    
    NSArray *orderedArray = data.query.orderBy(^(id item1, id item2){
        return [item1 compare:item2];
    }).array();
    BOOL isOrdered = [orderedArray isEqualToArray:@[@-4, @0, @1, @3, @9, @9, @55]];
    XCTAssert(isOrdered);
    
    NSArray *distincedArray = data.query.distinct().array();
    XCTAssert(distincedArray.count == 6);
    
    NSArray *reversedArray = data.query.reverse().array();
    isOrdered = [reversedArray isEqualToArray:@[@55, @-4, @9, @0, @9, @3, @1]];
    XCTAssert(isOrdered);
    
    NSString *joinString = data.query.join(@"+");
    BOOL isEquals = [@"1+3+9+0+9+-4+55" isEqualToString:joinString];
    XCTAssert(isEquals);
    
    NSArray *minusedArray = data.query.minus(@[@55, @0, @3]).array();
    isEquals = [minusedArray isEqualToArray:@[@1, @9, @9, @-4]];
    XCTAssert(isEquals);
    
    NSArray *addedArray = data.query.addAll(@[@920, @658]).array();
    isEquals = [addedArray isEqualToArray:@[@1, @3, @9, @0, @9, @-4, @55, @920, @658]];
    XCTAssert(isEquals);
    
    addedArray = data.query.add(@92).array();
    isEquals = [addedArray isEqualToArray:@[@1, @3, @9, @0, @9, @-4, @55, @92]];
    XCTAssert(isEquals);
    
    NSArray *flattenArray = [NSMutableArray arrayWithObjects:@1, @5, @8, @[@2, @6], @{@"3": @3, @"4": @4}, nil].query.flatten().array();
    isEquals = [flattenArray isEqualToArray:@[@1, @5, @8, @2, @6, AYPairMake(@"3", @3), AYPairMake(@"4", @4)]];
    XCTAssert(isEquals);
}

- (void)testConvert{
    NSDictionary *dic = self.data.query.groupBy(^(Student *stu){
        return [stu.name substringToIndex:1];
    }).dictionary(nil);
    
    XCTAssert([dic isKindOfClass:[NSDictionary class]]);
    BOOL isEquals = [[NSSet setWithArray:[dic allKeys]] isEqualToSet:[NSSet setWithObjects:@"张", @"王", @"吴", @"孙", nil]];
    XCTAssert(isEquals);
    
    NSArray *array = self.data.query.groupBy(^(Student *stu){
        return [stu.name substringToIndex:1];
    }).select(^(id item){
        return [item key];
    }).array();
    XCTAssert([array isKindOfClass:[NSArray class]]);
    isEquals = [[NSSet setWithArray:array] isEqualToSet:[NSSet setWithObjects:@"张", @"王", @"吴", @"孙", nil]];
    XCTAssert(isEquals);
    
    NSSet *set = self.data.query.groupBy(^(Student *stu){
        return [stu.name substringToIndex:1];
    }).select(^(id item){
        return [item key];
    }).set();
    XCTAssert([set isKindOfClass:[NSSet class]]);
    isEquals = [set isEqualToSet:[NSSet setWithObjects:@"张", @"王", @"吴", @"孙", nil]];
    XCTAssert(isEquals);
}
@end
