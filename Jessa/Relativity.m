//
//  Relativity.m
//  Jessa
//
//  Created by Rick Rothenberg on 6/1/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Relativity.h"
#import "Processing.h"

static float NUM_CIRCLES_PER_SQRT_AREA = 0.35;
static float REST_RADIUS_PER_SQRT_AREA = 0.0125;
static float maxVelocity = 3.25;
static float restRadius;
static int frameNumber = 0;

@implementation Relativity
+(void)createInstances {
    int area = width*height;
    restRadius = sqrt(area)*REST_RADIUS_PER_SQRT_AREA;
    int numCircles = sqrt(area)*NUM_CIRCLES_PER_SQRT_AREA;
    for (int i = 0;i < numCircles;i++) {
        [self addObject:[Relativity new]];
    }
}
+(void)update {
    NSMutableArray* elements = [self elements];
    for (int i = 0; i < [elements count] - 1; i++) {
        Relativity* element1 = [elements objectAtIndex:i];
        for (int j = i+1; j < [elements count]; j++) {
            Relativity* element2 = [elements objectAtIndex:j];
            float xDiff = element1->x - element2->x;
            float yDiff = element1->y - element2->y;
            float d2 = xDiff*xDiff + yDiff*yDiff;
            if (d2 > 0.9) {
                float d = sqrt(d2);
                float forceDueToCharge = 1.0/(d*d)*12.0;
                float forceDueToGravity = -1.0/d*element1->mass*element2->mass*0.0013;
                float force = forceDueToCharge + forceDueToGravity;
                [element1 updateVelocityUsingElement:element2 Force:force Distance:d];
                [element2 updateVelocityUsingElement:element1 Force:force Distance:d];
            }
        }
    }
    for (int i = 0; i < [elements count]; i++) {
        Relativity* element = [elements objectAtIndex:i];
        element->lastX = element->x;
        element->lastY = element->y;
        element->x += element->dx;
        element->y += element->dy;
        if (element->x>width*1.01 ||
            element->x<-width*0.01) {
            element->dx = -element->dx;
            element->x = element->lastX;
            element->y = element->lastY;
        }
        if (element->y>height*1.01 ||
            element->y<-height*0.01) {
            element->dy = -element->dy;
            element->x = element->lastX;
            element->y = element->lastY;
        }
    }
}
-(void)updateVelocityUsingElement: (Element*) other Force: (float) force Distance: (float) d {
    float xDiff = x - other->x;
    float yDiff = y - other->y;
    float acceleration = force/mass;
    float dxTemp = dx + xDiff/d*acceleration;
    float dyTemp = dy + yDiff/d*acceleration;
    float velocityTemp = sqrt(dxTemp*dxTemp+dyTemp*dyTemp);
    if (velocityTemp < maxVelocity) {
        dx = dxTemp;
        dy = dyTemp;
        velocity = velocityTemp;
        mass = restMass/sqrt(1-velocity*velocity/(maxVelocity*maxVelocity));
        radius = restRadius*(1-velocity/maxVelocity) + 5;
    }
    
}
-(void)initialize {
    x = randomMax(width*1.02) - width*0.01;
    y = randomMax(height*1.02) - height*0.01;
    velocity = 0.0;
    dx = 0.0;
    dy = 0.0;
    restMass = 5.0;
    mass = restMass;
    radius = restRadius;
}
-(void)draw:(Relativity*)other {
    float h1 = velocity/maxVelocity*255;
    float h2 = other->velocity/maxVelocity*255;
    float distance = [self distance: other];
    float distanceFactor = distance/(radius + other->radius)*255;
    float h = (h1 + h2)/2;
    strokeHSB(h,255,255 - distanceFactor,distanceFactor/4 + 20);
    line(x, y, other->x, other->y);
}
+(void)draw {
    frameNumber++;
    if (frameNumber == 90) {
        fillHSB(0.0, 0.0, 0.0, 0.5);
        background();
        frameNumber = 0;
    }
    NSMutableArray* elements = [self elements];
    strokeWeight(0.5);
    for (int i = 0; i < [elements count] - 1; i++) {
        // Get a first element
        Relativity* element1 = [elements objectAtIndex:i];
        //float h = element1->velocity/maxVelocity*255;
        //strokeHSB(0,0,h,150);
        //line(element1->lastX, element1->lastY, element1->x, element1->y);
        for (int j = i+1; j < [elements count]; j++) {
            // Get a second element
            Element* element2 = [elements objectAtIndex:j];
            // If the elements are touching
            if ([element1 touching:element2]) {
                [element1 draw:element2];
            }
        }
    }
}

@end
