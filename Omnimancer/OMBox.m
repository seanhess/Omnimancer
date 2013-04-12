//
//  OMBox.m
//  Omnimancer
//
//  Created by Sean Hess on 4/9/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import "OMBox.h"

@implementation OMBox
-(id)initWithType:(OMBoxType)type x:(NSInteger)x y:(NSInteger)y {
    self = [super init];
    if (self) {
        self.type = type;
        self.x = x;
        self.y = y;
    }
    return self;
}
@end