//
//  RZXCollider.m
//  RazePhysics
//
//  Created by Rob Visentin on 3/4/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <RazePhysics/RZXCollider.h>
#import <RazePhysics/RZXCollider_Private.h>

@implementation RZXCollider

- (instancetype)init
{
    if ( self = [super init] ) {
        _transform = [RZXTransform3D transform];
    }

    return self;
}

#pragma mark - private

- (BOOL)collidesWith:(RZXCollider *)other
{
    return NO;
}

@end
