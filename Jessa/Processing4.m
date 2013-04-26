//
//  Processing4.m
//  Jessa
//
//  Created by Rick Rothenberg on 4/23/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Processing4.h"
#import "Processing.h"

static float MIN_RADIUS_FACTOR = .5;
static float MAX_RADIUS_FACTOR = 2;

static float DELTA_ANGLE = TWO_PI/666;

static float NUM_CIRCLES_PER_SQRT_AREA = 0.25;

@implementation Processing4
-(void)initialize {
    float minRadius = MIN_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    float maxRadius = MAX_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    x = randomMax(width-2*maxRadius)+maxRadius;
    y = randomMax(height-2*maxRadius)+maxRadius;
    radius = randomRange(minRadius, maxRadius);
    heading = randomMax(TWO_PI);
    speed = randomRange(0.1,1.0);
    rotation = randomRange(-DELTA_ANGLE, DELTA_ANGLE);
    r = randomMax(255);
    g = 255 - r;
    b = randomRange(200, 255);
}
+(void)createInstances {
    int area = width*height;
    float sqrtArea = sqrtf(area);
    int numCircles = NUM_CIRCLES_PER_SQRT_AREA*sqrtArea;
    for (int i = 0;i < numCircles;i++) {
        [self addObject:[Processing4 new]];
    }
}

@end
