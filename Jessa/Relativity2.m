//
//  Relativity.m
//  Jessa
//
//  Created by Rick Rothenberg on 6/1/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Relativity2.h"
#import "Processing.h"

static float REST_RADIUS_PER_SQRT_AREA = 0.0125f;
static float maxVelocity = 1.5f;
static float restRadius;
//static int frameNumber = 0;

static float MIN_RADIUS_FACTOR = .5f;
static float MAX_RADIUS_FACTOR = 2;

static float NUM_CIRCLES_PER_SQRT_AREA = 0.25f;


@implementation Relativity2
+(void)createInstances {
    int area = width*height;
    restRadius = sqrtf(area)*REST_RADIUS_PER_SQRT_AREA;
    int numCircles = sqrtf(area)*NUM_CIRCLES_PER_SQRT_AREA;
    for (int i = 0;i < numCircles;i++) {
        [self addObject:[Relativity2 new]];
    }
}
+(void)update {
    NSMutableArray* elements = [self elements];
    for (int i = 0; i < [elements count] - 1; i++) {
        Relativity2* element1 = [elements objectAtIndex:i];
        for (int j = i+1; j < [elements count]; j++) {
            Relativity2* element2 = [elements objectAtIndex:j];
            float xDiff = element1->x - element2->x;
            float yDiff = element1->y - element2->y;
            float d2 = xDiff*xDiff + yDiff*yDiff;
            if (d2 < (element1->radius + element2->radius)*(element1->radius + element2->radius) && d2 > 0.9) {
                float d = sqrtf(d2);
                float force = 1.0f/(d*d)*25.0f;
                [element1 updateVelocityUsingElement:element2 Force:force Distance:d];
                [element2 updateVelocityUsingElement:element1 Force:force Distance:d];
            }
        }
    }
    for (int i = 0; i < [elements count]; i++) {
        Relativity2* element = [elements objectAtIndex:i];
        element->x += element->dx;
        element->y += element->dy;
        [element behavior2];
    }
}
-(void)updateVelocityUsingElement: (Element*) other Force: (float) force Distance: (float) d {
    float xDiff = x - other->x;
    float yDiff = y - other->y;
    float acceleration = force/mass;
    float dxTemp = dx + xDiff/d*acceleration;
    float dyTemp = dy + yDiff/d*acceleration;
    float velocityTemp = sqrtf(dxTemp*dxTemp+dyTemp*dyTemp);
    if (velocityTemp < maxVelocity) {
        dx = dxTemp;
        dy = dyTemp;
        velocity = velocityTemp;
        mass = restMass/sqrtf(1-velocity*velocity/(maxVelocity*maxVelocity));
    }
    
}
-(void)initialize {
    restMass = 5.0f;
    mass = restMass;
    float minRadius = MIN_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    float maxRadius = MAX_RADIUS_FACTOR*sqrtf(sqrtf(width*height));
    x = randomMax(width-2*maxRadius)+maxRadius;
    y = randomMax(height-2*maxRadius)+maxRadius;
    radius = randomRange(minRadius, maxRadius);
    heading = randomMax(TWO_PI);
    speed = randomRange(0.1f,1.0f);
    dx = sinf(heading)*speed;
    dy = cosf(heading)*speed;
    velocity = speed;
    r = randomMax(255);
    g = 255 - r;
    b = randomRange(200, 255);

}
@end
