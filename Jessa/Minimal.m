//
//  Minimal.m
//  Jessa
//
//  Created by Rick Rothenberg on 6/4/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Minimal.h"
#import "Processing.h"

static float RADIUS_PER_SQRT_AREA = 15.0/1000.0;

static float DELTA_ANGLE = TWO_PI/333;

static float NUM_CIRCLES_PER_AREA = 400.0/(1000.0*1000.0);

static float fixedRadius;

@implementation Minimal
-(void)initialize {
    radius = fixedRadius;
    x = randomMax(width-2*radius)+radius;
    y = randomMax(height-2*radius)+radius;
    heading = randomMax(TWO_PI);
    speed = 0.5;
    rotation = randomRange(-DELTA_ANGLE, DELTA_ANGLE);
    rotation = TWO_PI/(floor(TWO_PI/rotation)+.5);
    h = randomMax(25.0);
}
+(void)createInstances {
    int area = width*height;
    float sqrtArea = sqrt(width*height);
    int numCircles = NUM_CIRCLES_PER_AREA*area;
    fixedRadius = RADIUS_PER_SQRT_AREA*sqrtArea;
    for (int i = 0;i < numCircles;i++) {
        [self addObject:[Minimal new]];
    }
}
-(void)draw:(Minimal*)other {
    float distance = [self distance:other];
    float alpha = 255 - distance/(radius + other->radius)*255;
    float hue = h < other->h ? h : other->h;
    strokeHSB(hue,alpha,alpha,alpha/10 + 10);
    line(x, y, other->x, other->y);
}
+(int)numberFramesPerFade {
    return 1000;
}
@end
