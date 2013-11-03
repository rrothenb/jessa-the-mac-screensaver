//
//  Musical.h
//  Jessa
//
//  Created by Rick Rothenberg on 6/1/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"

@interface Musical : Element {
    double dx;
    double dy;
    double mass;
    double restMass;
    double velocity;
    double lastX;
    double lastY;
    double volume;
    double globalSonance;
    int pitchOctave;
    int pitchNumerator;
    int pitchDenominator;
}
+(void)update;
+(void)createInstances;
-(void)updateVelocityUsingElement: (Element*) other Force: (double) force Distance: (double) distance WidthOffset: (int) widthOffset HeightOffset: (int) heightOffset;
-(void)draw:(Element*)other WidthOffset: (int) widthOffset HeightOffset: (int) heightOffset Distance: (double) distance;
+(void)draw;
-(id)initWithOctave: (int) octave numerator: (int) numerator denominator: (int) denominator;
-(double)calcSonance: (Musical*)other;
-(Boolean)touching: (Element*) other ThresholdMultiplier: (double) thresholdMultiplier DistanceSquared: (double*) distance WidthOffset: (int*) widthOffset HeightOffset: (int*) heightOffset;
@end
