//
//  RZXPhysicsWorld.m
//  RazePhysics
//
//  Created by Rob Visentin on 4/1/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//


#import <RazePhysics/RZXPhysicsWorld.h>
#import <RazePhysics/RZXCollider_Private.h>
#import <RazePhysics/RZXPhysicsBody_Private.h>

@implementation RZXPhysicsWorld {
    NSMutableSet *_bodies;
    NSMutableSet *_currentContacts;
    NSMutableSet *_frameContacts;
}

- (instancetype)init
{
    if ( (self = [super init]) ) {
        _bodies = [NSMutableSet set];
        _currentContacts = [NSMutableSet set];
        _frameContacts = [NSMutableSet set];
        _gravity = GLKVector3Make(0.0f, -9.8f, 0.0f);
    }

    return self;
}

- (void)addBody:(RZXPhysicsBody *)body
{
    if ( body != nil ) {
        [_bodies addObject:body];
        body.world = self;
    }
}

- (void)removeBody:(RZXPhysicsBody *)body
{
    if ( body != nil ) {
        [_bodies removeObject:body];

        if ( body.world == self ) {
            body.world = nil;
        }
    }
}

- (RZXPhysicsBody *)bodyAtPoint:(GLKVector3)point
{
    __block RZXPhysicsBody *body = nil;

    [self enumerateBodiesAtPoint:point withBlock:^(RZXPhysicsBody *b, BOOL *stop) {
        body = b;
        *stop = YES;
    }];

    return body;
}

- (void)enumerateBodiesAtPoint:(GLKVector3)point withBlock:(RZXPhysicsBodyEnumeration)block
{
    [self enumerateBodiesWithBlock:^(RZXPhysicsBody *body, BOOL *stop) {
        if ( [body.collider pointInside:point] ) {
            block(body, stop);
        }
    }];
}

- (void)enumerateBodiesWithBlock:(RZXPhysicsBodyEnumeration)block
{
    [_bodies enumerateObjectsUsingBlock:block];
}

#pragma mark - RZXUpdateable

- (void)rzx_update:(NSTimeInterval)dt
{
    NSArray *bodies = _bodies.allObjects;

    GLKVector3 gravity = GLKVector3MultiplyScalar(self.gravity, dt);

    for ( RZXPhysicsBody *body in bodies ) {
        [body prepareForUpdates];

        if ( body.isDynamic && body.isAffectedByGravity && body.mass > 0.0f ) {
            [body adjustVelocity:gravity];
        }
    }

    [self resolveContactsForBodies:bodies];

    for ( RZXPhysicsBody *body in bodies ) {
        [body rzx_update:dt];
        [body finalizeUpdates];
    }

    if ( self.delegate != nil ) {
        [self notifyContactDelegate];
    }

    NSMutableSet *tmp = _currentContacts;
    _currentContacts = _frameContacts;
    _frameContacts = tmp;

    [_frameContacts removeAllObjects];
}

#pragma mark - private

- (void)resolveContactsForBodies:(NSArray *)bodies
{
    // iterate over all pairs of bodies
    for ( NSUInteger i = 0; i< bodies.count; ++i ) {
        for ( NSUInteger j = i + 1; j < bodies.count; ++j ) {
            RZXPhysicsBody *first = bodies[i];
            RZXPhysicsBody *second = bodies[j];

            BOOL firstCollides = first.isDynamic && [first.collider shouldCollideWith:second.collider];
            BOOL secondCollides = second.isDynamic && [second.collider shouldCollideWith:first.collider];

            if ( firstCollides || secondCollides ) {
                RZXContact *contact = [first generateContact:second];

                if ( contact != nil ) {
                    [first addContactedBody:second];
                    [second addContactedBody:first];

                    [self resolveContact:contact];
                    [_frameContacts addObject:contact];
                }
            }
        }
    }
}

- (void)resolveContact:(RZXContact *)contact
{
    RZXPhysicsBody *first = contact.first;
    RZXPhysicsBody *second = contact.second;

    GLKVector3 normal = contact.normal;
    GLKVector3 relativeVelocity = GLKVector3Subtract(first.velocity, second.velocity);

    float firstInvMass = first.inverseMass;
    float secondInvMass = second.inverseMass;

    float relativeNormalVelocity = GLKVector3DotProduct(relativeVelocity, normal);

    float totalInverseMass = MAX(FLT_EPSILON, (firstInvMass + secondInvMass));
    float cor = 0.5f * (first.restitution + second.restitution);

    float magnitude = (1.0f + cor) * relativeNormalVelocity / totalInverseMass;

    GLKVector3 impulse = GLKVector3MultiplyScalar(normal, magnitude);

    BOOL firstCollides = first.isDynamic && [first.collider shouldCollideWith:second.collider];
    BOOL secondCollides = second.isDynamic && [second.collider shouldCollideWith:first.collider];

    if ( firstCollides && secondCollides ) {
        [first adjustVelocity:GLKVector3MultiplyScalar(impulse, -firstInvMass)];
        [first adjustPosition:GLKVector3MultiplyScalar(normal, (firstInvMass / totalInverseMass) * contact.distance)];

        [second adjustVelocity:GLKVector3MultiplyScalar(impulse, secondInvMass)];
        [second adjustPosition:GLKVector3MultiplyScalar(normal, -(secondInvMass / totalInverseMass) * contact.distance)];
    }
    else if ( firstCollides ) {
        [first adjustVelocity:GLKVector3MultiplyScalar(impulse, -firstInvMass)];
        [first adjustPosition:GLKVector3MultiplyScalar(normal, contact.distance)];
    }
    else if ( secondCollides ) {
        [second adjustVelocity:GLKVector3MultiplyScalar(impulse, secondInvMass)];
        [second adjustPosition:GLKVector3MultiplyScalar(normal, -contact.distance)];
    }
}

- (void)notifyContactDelegate
{
    NSMutableSet *newContacts = [_frameContacts mutableCopy];
    [newContacts minusSet:_currentContacts];

    for ( RZXContact *contact in newContacts ) {
        [self.delegate contactDidBegin:contact];
    }

    NSMutableSet *oldContacts = [_currentContacts mutableCopy];
    [oldContacts minusSet:_frameContacts];

    for ( RZXContact *contact in oldContacts ) {
        [self.delegate contactDidEnd:contact];
    }
}

@end