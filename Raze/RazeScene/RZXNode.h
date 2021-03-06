//
//  RZXNode.h
//  RazeScene
//
//  Created by John Stricker on 4/17/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>

#import <RazeCore/RZXGPUObject.h>
#import <RazeCore/RZXRenderable.h>
#import <RazeCore/RZXUpdateable.h>

@class RZXTransform3D;
@class RZXEffect;
@class RZXCamera;

/**
 *  The base unit of any scene object. In most cases anything applied to a node (transform, camera, effect, animation) will also be applied to that node's children if the child node does not have a value specified.
 */
@interface RZXNode : RZXGPUObject <RZXRenderable, RZXUpdateable>

@property (strong, nonatomic) RZXTransform3D *transform;
@property (strong, nonatomic) RZXEffect *effect;
@property (strong, nonatomic) RZXCamera *camera;

@property (assign, nonatomic) GLKVector2 resolution;

@property (copy, nonatomic, readonly) NSArray *children;
@property (weak, nonatomic, readonly) RZXNode *parent;

+ (instancetype)node;

- (void)addChild:(RZXNode *)child;
- (void)insertChild:(RZXNode *)child atIndex:(NSUInteger)index;

- (void)removeFromParent;

- (GLKMatrix4)modelMatrix;
- (GLKMatrix4)viewMatrix;
- (GLKMatrix4)projectionMatrix;

- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key;
- (CAAnimation *)animationForKey:(NSString *)key;
- (void)removeAnimationForKey:(NSString *)key;

@end
