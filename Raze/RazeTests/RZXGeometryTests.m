//
//  RazeGeometryTests.m
//  RazeTests
//
//  Created by Jason Clark on 6/6/16.
//  Copyright (c) 2016 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RZXGeometry.h"

@import RazePhysics;

@interface RazeGeometryTests : XCTestCase

@end

@implementation RazeGeometryTests

#pragma mark - Spheres

- (void)testRZXSphereContainsPoint {

    RZXSphere sphere;
    sphere.center = GLKVector3Make(0, 0, 0);
    sphere.radius = 10.0;

    GLKVector3 point = GLKVector3Make(0, 0, 0);

    //Base case: Sphere contains own center
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //Base failure
    sphere.radius = 10.0;
    point = GLKVector3Make(sphere.radius + 1, 0, 0);
    XCTAssert(RZXSphereContainsPoint(sphere, point) == false);

    //point on sphere surface
    point = GLKVector3Make(sphere.radius, 0, 0);
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //Negative radius
    point = GLKVector3Make(0, 0, 0);
    sphere.radius = -10.0;
    XCTAssert(RZXSphereContainsPoint(sphere, point) == false);

    //point on sphere surface, non-zero center
    point = GLKVector3Make(0, 0, 0);
    sphere.center = GLKVector3Make(10, 0, 0);
    sphere.radius = 10;
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //zero-size sphere
    sphere.center = GLKVector3Make(0, 0, 0);
    sphere.radius = 0.0;
    point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXSphereContainsPoint(sphere, point));

    //test overflow
    sphere.center = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
	sphere.radius = INFINITY;
    point = GLKVector3Make(FLT_MAX, FLT_MAX, FLT_MAX);
    XCTAssert(RZXSphereContainsPoint(sphere, point));

}

- (void)testRZXSphereIntersectsSphere {

    RZXSphere sphere1, sphere2;
    sphere1.center = GLKVector3Make(0, 0, 0);
    sphere1.radius = 10.0f;

    sphere2 = sphere1;

    RZXContactData contactData;

    //identity
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2, &contactData));
    XCTAssertEqual(contactData.distance, 0.0f);

    //same centers
    sphere2.radius = sphere1.radius / 2.0f;
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2, &contactData));
    XCTAssertEqual(contactData.distance, sphere2.radius);

    //touching surfaces
    sphere1.radius = sphere2.radius = 10.0f;
    sphere1.center.x = -10.0f;
    sphere2.center.x = 10.0f;
    XCTAssert(RZXSphereIntersectsSphere(sphere1, sphere2, NULL));

    //barely not touching
    sphere2.center.x += (1.0/100000.0);
    XCTAssertFalse(RZXSphereIntersectsSphere(sphere1, sphere2, NULL));

    //not touching
    sphere2.center.x += 1;
    XCTAssertFalse(RZXSphereIntersectsSphere(sphere1, sphere2, NULL));

}

#pragma mark - Boxes

-(void)testRZXBoxGetSize {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);
    box.radius = GLKVector3Make(10, 10, 10);
    box.axes[0] = GLKVector3Make(0, 0, 0);
    box.axes[1] = GLKVector3Make(0, 0, 0);
    box.axes[2] = GLKVector3Make(0, 0, 0);

    //base case
    GLKVector3 expectedResult = GLKVector3Make(20, 20, 20);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //move center
    box.center = GLKVector3Make(10, 10, 10);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //off axis
    box.axes[0] = GLKVector3Make(0, 1, 0);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //negative dimenions
    box.radius = GLKVector3Make(-10, -10, -10);
    expectedResult = GLKVector3Make(-20, -20, -20);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

    //non-cube
    box.radius = GLKVector3Make(1, 2, 3);
    expectedResult = GLKVector3Make(2, 4, 6);
    XCTAssert(GLKVector3AllEqualToVector3(RZXBoxGetSize(box), expectedResult));

}

-(void)testRZXBoxGetRotation {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);
    box.radius = GLKVector3Make(1, 1, 1);
    box.axes[0] = GLKVector3Make(1, 0, 0);
    box.axes[1] = GLKVector3Make(0, 1, 0);
    box.axes[2] = GLKVector3Make(0, 0, 1);

    //Identity
    NSString *result = NSStringFromGLKQuaternion(RZXBoxGetRotation(box));
    NSString *expectedResult = NSStringFromGLKQuaternion(GLKQuaternionIdentity);
    XCTAssert([result isEqualToString: expectedResult], "expected '%@' to equal '%@'", result, expectedResult);
}

-(void)testRZXBoxGetNearestPoint {

}

-(void)testRZXBoxContainsPoint {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);
    box.radius = GLKVector3Make(1, 1, 1);
    box.axes[0] = GLKVector3Make(1, 0, 0);
    box.axes[1] = GLKVector3Make(0, 1, 0);
    box.axes[2] = GLKVector3Make(0, 0, 1);

    //base case
    GLKVector3 point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXBoxContainsPoint(box, point));

    //point on box surface
    point = GLKVector3Make(0, 0, 1);
    XCTAssert(RZXBoxContainsPoint(box, point));

    //point just beyond box surface
    point = GLKVector3Make(0, 0, 1.1);
    XCTAssert(RZXBoxContainsPoint(box, point) == false);

    //no radius
    box.radius = GLKVector3Make(0, 0, 0);
    point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXBoxContainsPoint(box, point));

    //point on corner, translated box
    box.center = GLKVector3Make(1, 1, 1);
    box.radius = GLKVector3Make(1, 1, 1);
    point = GLKVector3Make(0, 0, 0);
    XCTAssert(RZXBoxContainsPoint(box, point));

}

-(void)testRZXBoxTranslate {
    RZXBox box;
    box.center = GLKVector3Make(0, 0, 0);

    GLKVector3 translation = GLKVector3Make(0, 1, 0);
    GLKVector3 expectedLocation = GLKVector3Make(0, 1, 0);
    RZXBoxTranslate(&box, translation);
    XCTAssert(GLKVector3AllEqualToVector3(box.center, expectedLocation));

    translation = GLKVector3Make(1, 0, 1);
    expectedLocation = GLKVector3Make(1, 1, 1);
    RZXBoxTranslate(&box, translation);
    XCTAssert(GLKVector3AllEqualToVector3(box.center, expectedLocation));

    translation = GLKVector3Make(-1, -1, -1);
    expectedLocation = GLKVector3Make(0, 0, 0);
    RZXBoxTranslate(&box, translation);
    XCTAssert(GLKVector3AllEqualToVector3(box.center, expectedLocation));
}

-(void)testRZXBoxScale {
    RZXBox box;
    box.radius = GLKVector3Make(1, 1, 1);
    GLKVector3 scale = GLKVector3Make(1, 1, 1);
    GLKVector3 expectedRadius = GLKVector3Make(1, 1, 1);

    //identity
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));

    scale = GLKVector3Make(1, 2, 3);
    expectedRadius = GLKVector3Make(1, 2, 3);
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));

    scale = GLKVector3Make(-1, -2, -3);
    expectedRadius = GLKVector3Make(-1, -4, -9);
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));

    scale = GLKVector3Make(0, 0, 0);
    expectedRadius = GLKVector3Make(0, 0, 0);
    RZXBoxScale(&box, scale);
    XCTAssert(GLKVector3AllEqualToVector3(box.radius, expectedRadius));
}

-(void)testRZXBoxRotate {

}

- (void)testRZXBoxIntersection {
    RZXBox b1 = RZXBoxMakeAxisAligned(RZXVector3Zero, GLKVector3Make(1.0f, 1.0f, 1.0f));
    RZXBox b2 = RZXBoxMakeAxisAligned(GLKVector3Make(0.5f, 0.5f, 0.5f), GLKVector3Make(1.0f, 1.0f, 1.0f));

    // simple intersection
    XCTAssert(RZXBoxIntersectsBox(b1, b2, NULL));

    // single point intersection (corner)
    b2.center = GLKVector3Make(2.0f, 2.0f, 2.0f);
    XCTAssert(RZXBoxIntersectsBox(b1, b2, NULL));

    // no intersection
    b2.center = GLKVector3Make(3.0f, 3.0f, 3.0f);
    XCTAssertFalse(RZXBoxIntersectsBox(b1, b2, NULL));

    // introduce rotation
    GLKVector3 axis = GLKVector3Normalize(GLKVector3Make(1.0f, 1.0f, 1.0f));
    RZXBoxRotate(&b1, GLKQuaternionMakeWithAngleAndVector3Axis(M_PI_4, axis));
    RZXBoxRotate(&b2, GLKQuaternionMakeWithAngleAndVector3Axis(-0.5f * M_PI_4, axis));
    RZXBoxScale(&b1, GLKVector3Make(2.0f, 2.0f, 2.0f));
    XCTAssert(RZXBoxIntersectsBox(b1, b2, NULL));

    // no intersection w/ rotation
    b2.center = GLKVector3Make(5.0f, 5.0f, 5.0f);
    XCTAssertFalse(RZXBoxIntersectsBox(b1, b2, NULL));

    // would intersect if not rotated
    b1 = RZXBoxMakeAxisAligned(GLKVector3Make(0.0f, 8.0f, -8.0f), GLKVector3Make(1.0f, 1.0f, 1.0f));
    b2 = RZXBoxMakeAxisAligned(GLKVector3Make(0.0f, -2.0f, 0.0f), GLKVector3Make(25.0f, 25.0f, 0.1f));
    RZXBoxRotate(&b2, GLKQuaternionMakeWithAngleAndAxis(M_PI_2, 1.0f, 0.0f, 0.0f));
    XCTAssertFalse(RZXBoxIntersectsBox(b1, b2, NULL));
}


@end