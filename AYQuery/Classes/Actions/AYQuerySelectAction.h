//
//  AYQuerySelectAction.h
//  Pods
//
//  Created by PoiSon on 16/7/30.
//
//

#import "AYQueryAction.h"

@interface AYQuerySelectAction : AYQueryAction
@property (nonatomic, readonly) id (^block)(id e);
@end
