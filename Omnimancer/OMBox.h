//
//  OMBox.h
//  Omnimancer
//
//  Created by Sean Hess on 4/9/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import <Foundation/Foundation.h>

// store the position here. Why not?

typedef enum OMBoxType {
    OMBoxTypeGrass,
} OMBoxType;

@interface OMBox : NSObject
@property (nonatomic) OMBoxType type;
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
-(id)initWithType:(OMBoxType)type x:(NSInteger)x y:(NSInteger)y;
@end

