//
//  AYQueryDictionaryTests.m
//  AYQuery
//
//  Created by alan on 2016/11/10.
//  Copyright © 2016年 Alan Yeh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AYQuery/AYQuery.h>

@interface AYQueryDictionaryTests : XCTestCase
@property (nonatomic, strong) NSMutableDictionary *data;
@end

@implementation AYQueryDictionaryTests

- (void)setUp {
    [super setUp];
    self.data = [NSMutableDictionary new];
    for (NSInteger i = 1; i < 1000; i ++) {
        if (i % 2 == 0) {
            [self.data setObject:@(i) forKey:[NSString stringWithFormat:@"张%@", @(i)]];
        }
        
        if (i % 3 == 0) {
            [self.data setObject:@(i) forKey:[NSString stringWithFormat:@"王%@", @(i)]];
        }
        
        if (i % 5 == 0) {
            [self.data setObject:@(i) forKey:[NSString stringWithFormat:@"吴%@", @(i)]];
        }
        
        if (i % 7 == 0) {
            [self.data setObject:@(i) forKey:[NSString stringWithFormat:@"孙%@", @(i)]];
        }
    }
}

- (void)testFind{
    NSArray *array = self.data.query.array();
    for (AYPair *pair in array) {
        XCTAssert([pair isKindOfClass:[AYPair class]]);
    }
    
    NSArray *sunStu = self.data.query.findAll(^BOOL(AYPair *item){
        return [item.key hasPrefix:@"孙"];
    }).array();
    
    XCTAssert(sunStu.count == 142);
    
    AYPair *result = self.data.query.find(^BOOL(id item){
        return [[item key] hasPrefix:@"张"];
    });
    BOOL isEquals = [result.key hasPrefix:@"张"];
    XCTAssert(isEquals);
}

- (void)testSelect{
    NSArray *names = self.data.query.select(^(AYPair *item){
        return item.key;
    }).array();
    
    XCTAssert(names.count == self.data.count);
    for (NSString *name in names) {
        XCTAssert([name isKindOfClass:[NSString class]]);
    }
}

- (void)testGroupBy{
    NSArray *groups = self.data.query.groupBy(^(AYPair *item){
        return [item.key substringWithRange:NSMakeRange(0, 1)];
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
    XCTAssert(skips.count == self.data.count - 3);
    
    //取10个item
    NSArray *takes = self.data.query.take(10).array();
    XCTAssert(takes.count == 10);
    
    //取范围
    NSArray *ranges = self.data.query.rangeOf(3, 3).array();
    XCTAssert(ranges.count == 3);
}


@end
