//
//  Element.m
//  Jessa
//
//  Created by Rick Rothenberg on 3/28/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"
#import "Processing.h"

static int frameNumber = 0;

static int numberFramesPerFade;

@implementation Element
static NSMutableArray *elements;
+(void)initializeWithView:(NSView*) view {
    [super initialize];
    NSSize size;
    size = [view bounds].size;
    initializeProcessing((float)size.width, (float)size.height);
    elements = [[NSMutableArray alloc] init];
    [self createInstances];
    numberFramesPerFade = [self numberFramesPerFade];
}
+(void)createInstances {
}
+(void)addObject:(Element*) element {
    [elements addObject:element];
}
+(NSMutableArray*) elements {
    return elements;
}
+(void)update {
    Element* element;
    for (element in elements) {
        [element update];
    }
}
+(id)new {
    return [super new];
}
-(id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}
-(void)initialize {
}
-(void)update {
    [self behavior1];
    [self behavior2];
    [self behavior3];
}
-(void)behavior1 {
    // Constant linear motion
    float dx = speed * cosf(heading);
    float dy = speed * sinf(heading);
    x += dx;
    y += dy;
}
-(void)behavior2 {
    // Constrain to surface
    if (x < radius) {
        x = radius;
        heading = PI - heading;
    }
    if (y < radius) {
        y = radius;
        heading = TWO_PI - heading;
    }
    if (x > width - radius) {
        x = width - radius;
        heading = PI - heading;
    }
    if (y > height - radius) {
        y = height - radius;
        heading = TWO_PI - heading;
    }
}
-(void)behavior3 {
    // While touching another, change direction
    if ([self touching]) {
        heading += rotation;
    }
}
-(Boolean)touching:(Element*)other {
    float threshold = (radius + other->radius)*(radius + other->radius);
    float distanceSquared = (x - other->x)*(x - other->x) + (y - other->y)*(y - other->y);
    return distanceSquared < threshold;
}
-(Boolean)touching {
    Element* element;
    for (element in elements) {
        if (element != self) {
            if ([self touching:element]) {
                return true;
            }
        }
    }
    return false;
}
-(float)distance:(Element*)other {
    return dist(x, y, other->x, other->y);
}
+(void)draw {
    frameNumber++;
    if (frameNumber == numberFramesPerFade) {
        fillHSB(0.0f, 0.0f, 0.0f, 0.5f);
        background();
        frameNumber = 0;
    }
    strokeWeight(0.5f);
    for (int i = 0; i < [elements count]; i++) {
        // Get a first element
        Element* element1 = [elements objectAtIndex:i];
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
-(void)draw:(Element*)other {
    float distance = [self distance:other];
    float value = distance/(radius + other->radius);
    float red = (r + other->r)/2*value;
    float green = (g + other->g)/2*value;
    float blue = (b + other->b)/2*value;
    stroke(red, green, blue, 25);
    
    // Draw a line between the centres of the elements
    line(x, y, other->x, other->y);
}
+(int)numberFramesPerFade {
    return 30;
}

@end


