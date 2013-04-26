 //
//  Lissajous1.m
//  Jessa
//
//  Created by Rick Rothenberg on 4/20/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Lissajous1.h"
#import "Processing.h"

int primes[] = {2,3,5,7,11,13,17,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163};
int firstPrime = 1;
int lastPrime = 20;

@implementation Lissajous1
+(void)createInstances {
    for (int i = firstPrime; i < lastPrime; i++) {
        for (int j = i + 1; j <= lastPrime; j++) {
            [self addObject:[[Lissajous1 alloc] initWithF1:primes[i] f2:primes[j] dt:0.001]];
            [self addObject:[[Lissajous1 alloc] initWithF1:primes[j] f2:primes[i] dt:-0.001]];
        }
    }
}
-(id)initWithF1: (int) _f1 f2: (int) _f2 dt: (float) _dt {
    self = [super init];
    if (self) {
        f1 = _f1;
        f2 = _f2;
        t = randomRange(0.0, TWO_PI);
        dt = _dt/(f1+f2);
        
        //h = randomRange(0, 255);
        
        float fMax = primes[lastPrime] + primes[lastPrime-1];
        float fMin = primes[firstPrime] + primes[firstPrime+1];
        float f = f1 + f2;
        
        h = 255 - (15 + (f - fMin)/(fMax - fMin)*(240 - 15));
        
        radius = fMax + 5 - f;
    }
    return self;
}
-(void)update {
    x = width/2 + (width-10)/2*sin(f1*t);
    y = height/2 + (height-10)/2*cos(f2*t);
    t = t + dt;
}
-(void)draw:(Lissajous1*)other {
    float distance = [self distance:other];
    float alpha = 255 - distance/(radius + other->radius)*255;
    float hue = (h + other->h)/2;
    strokeHSB(hue,255,alpha,alpha);
    line(x, y, other->x, other->y);
    strokeHSB(h,h,255,h);
    point(x, y);
    strokeHSB(other->h,other->h,255,other->h);
    point(other->x, other->y);
    
}

@end
