//
//  Element.m
//  Jessa
//
//  Created by Rick Rothenberg on 3/28/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"
#import "Processing.h"

@implementation Element
static NSMutableArray *elements;
+(void)initializeWithView:(NSView*) view {
    [super initialize];
    NSSize size;
    size = [view bounds].size;
    initializeProcessing(size.width, size.height);
    elements = [[NSMutableArray alloc] init];
    [self createInstances];
}
+(void)createInstances {
}
+(void)addObject:(Element*) element {
    [elements addObject:element];
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
    float dx = speed * cos(heading);
    float dy = speed * sin(heading);
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
    Element* element;
    for (element in elements) {
        if (element != self) {
            if ([self touching:element]) {
                heading += rotation;
                return;
            }
        }
    }
}
-(Boolean)touching:(Element*)other {
    float threshold = (radius + other->radius)*(radius + other->radius);
    float distanceSquared = (x - other->x)*(x - other->x) + (y - other->y)*(y - other->y);
    return distanceSquared < threshold;
}
-(float)distance:(Element*)other {
    return dist(x, y, other->x, other->y);
}
+(void)draw {
    strokeWeight(0.5);
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

@end

