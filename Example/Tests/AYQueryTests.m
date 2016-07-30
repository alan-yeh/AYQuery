//
//  AYQueryTests.m
//  AYQuery
//
//  Created by PoiSon on 16/7/30.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AYQuery/AYQuery.h>

#import "Student.h"
#import "Teacher.h"

@interface AYQueryTests : XCTestCase
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation AYQueryTests


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

- (void)testWhere{
    NSArray *sunStu = self.data.query.where(^BOOL(Student *stu){
        return [stu.name hasPrefix:@"孙"];
    }).array;
    
    XCTAssert(sunStu.count == 142);
    
    for (Student *stu in sunStu) {
        XCTAssert([stu.name hasPrefix:@"孙"]);
    }
}

- (void)testSelect{
    NSArray *names = self.data.query.select(^(Student *stu){
        return stu.name;
    }).array;
    
    XCTAssert(names.count == self.data.count);
    
    for (NSString *name in names) {
        XCTAssert([name isKindOfClass:[NSString class]]);
    }
}

- (void)testOfType{
    NSArray *teas = self.data.query.ofType([Teacher class]).array;
    
    XCTAssert(teas.count == 333);
    
    for (id obj in teas) {
        XCTAssert([obj isKindOfClass:[Teacher class]]);
    }
}

- (void)testGroupBy{
    NSArray *groups = self.data.query.groupBy(^(Student *stu){
        return [stu.name substringWithRange:NSMakeRange(0, 1)];
    }).array;
    
    XCTAssert(groups.count == 4);
}

- (void)testRange{
    NSArray *skips = self.data.query.skip(3).array;
    XCTAssert([[skips[0] name] isEqualToString:[self.data[3] name]]);
    XCTAssert(skips.count == self.data.count - 3);
    
    NSArray *takes = self.data.query.take(10).array;
    XCTAssert(takes.count == 10);
    
    NSArray *ranges = self.data.query.rangeOf(3, 3).array;
    XCTAssert(ranges.count == 3);
}

- (void)testTuple{
    AYTuple *tuple = AYTupleObject(Key = @"abc", Value = @"value");
    NSString *key = tuple.value[@"Key"];
    NSString *value = tuple.value[@"Value"];
    XCTAssert([key isEqualToString:@"abc"]);
    XCTAssert([value isEqualToString:@"value"]);
}

@end
