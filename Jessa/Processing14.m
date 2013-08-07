//
//  Processing14.m
//  Jessa
//
//  Created by Rick Rothenberg on 5/3/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Processing14.h"
#import "Processing.h"

static float MIN_RADIUS_FACTOR = .2;
static float MAX_RADIUS_FACTOR = 1;

static float DELTA_ANGLE = TWO_PI/666;

static float NUM_CIRCLES_PER_SQRT_AREA = 0.5;

@implementation Processing14
-(void)initialize {
    float minRadius = MIN_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    float maxRadius = MAX_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    x = randomMax(width-2*maxRadius)+maxRadius;
    y = randomMax(height-2*maxRadius)+maxRadius;
    radius = randomRange(minRadius, maxRadius);
    heading = randomMax(TWO_PI);
    speed = randomRange(0.1,1.0);
    rotation = randomRange(-DELTA_ANGLE, DELTA_ANGLE);
    h = randomRange(0, 50);
}
+(void)createInstances {
    int area = width*height;
    float sqrtArea = sqrtf(area);
    int numCircles = NUM_CIRCLES_PER_SQRT_AREA*sqrtArea;
    for (int i = 0;i < numCircles;i++) {
        [self addObject:[Processing14 new]];
    }
}

-(void)draw:(Processing14*)other {
    float distance = [self distance:other];
    float distanceFactor = distance/(radius + other->radius)*255;
    float hue = (h + other->h)/2;
    strokeHSB(hue,255,255-distanceFactor,(255-distanceFactor)/8);
    circle((x+other->x)/2, (y+other->y)/2, distance/2);
    strokeHSB(hue,255 - distanceFactor,255,(255-distanceFactor)/8);
    circle((x+other->x)/2, (y+other->y)/2, distance/2-2);
}
+(int)numberFramesPerFade {
    return 5;
}
@end
