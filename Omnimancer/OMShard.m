//
//  OMShard.m
//  Omnimancer
//
//  Created by Sean Hess on 4/9/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import "OMShard.h"
#import "OMBox.h"

@interface OMShard ()
@property (nonatomic) NSMutableArray * grid;
@end

@implementation OMShard

-(id)init {
    self = [super init];
    if (self) {
        self.grid = [NSMutableArray new];
        
        int y = 0;
        for (int x = -100; x < 100; x++) {
            [self.grid addObject:[[OMBox alloc] initWithType:OMBoxTypeGrass x:x y:y]];
        }
    }
    return self;
}

- (NSArray*)allBoxes {
    return self.grid;
}

@end
