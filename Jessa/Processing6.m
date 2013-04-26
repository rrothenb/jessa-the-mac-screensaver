//
//  Processing6.m
//  Jessa
//
//  Created by Rick Rothenberg on 4/23/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Processing6.h"
#import "Processing.h"

static float MIN_RADIUS_FACTOR = .5;
static float MAX_RADIUS_FACTOR = 2;

static float DELTA_ANGLE = TWO_PI/2666;

static float NUM_CIRCLES_PER_SQRT_AREA = 0.05;

@implementation Processing6

-(void)initialize {
    float minRadius = MIN_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    float maxRadius = MAX_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    x = width/2;
    y = height/2;
    radius = randomRange(minRadius, maxRadius);
    heading = randomMax(TWO_PI);
    speed = randomRange(0.1,1.0);
    rotation = randomRange(-DELTA_ANGLE, DELTA_ANGLE);
    r = randomRange(128, 255);
    g = randomRange(128, 255);
    b = 0;
}
-(void)behavior2 {
    // Constrain to surface
    float distance = dist(x, y, width/2, height/2) + radius;
    if (distance > width/2 || distance > height/2) {
        x = width/2;
        y = height/2;
    }
}
+(void)createInstances {
    int area = width*height;
    float sqrtArea = sqrtf(area);
    int numCircles = NUM_CIRCLES_PER_SQRT_AREA*sqrtArea;
    for (int i = 0;i < numCircles;i++) {
        [self addObject:[Processing6 new]];
    }
}
@end
