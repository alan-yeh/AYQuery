//
//  AYQueryWhereAction.h
//  Pods
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYQueryAction.h"

@interface AYQueryWhereAction : AYQueryAction
@property (nonatomic, readonly) BOOL (^block)(id e);
@end
