//
//  Musical.m
//  Jessa
//
//  Created by Rick Rothenberg on 6/1/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

/*
 Notes
 
 Try using a just intonation of 1:1, 9:8, 5:4, 4:3, 3:2, 5:3, 15:8, 2:1
 
 Actually keep track of both and do comparisons as rational numbers so can determine the sonance (size of the denominator?)
 
 Stick with A major for now
 
 Limit to notes on a piano - 55 (A1) to 3520 (A7)
 
 Should be able to ignore octaves and just compute sonance for the 21 combinations.  In some cases it will be less if go into next octave perhaps?  Or maybe it is simpler to just compute correctly on fly
 
 Perfect sonance has no repulsion
 
 Repulsion is a function of both sonance and volume
 
 What about global volume of a octave independent pitch?  If C1 is playing somewhere, should B5 be rejected by everything?  Is B5 to C5 the same as B5 to C1?
 
 Keep in mind that we somehow want to encourage the emergent behavior of voice leading.  Since global sonance is calculated and part of the equation, then this would be discouraged.
 
 What if each point represented a note?  certain intervals would attract, others would repulse.  Left right balance could be based on location.  Could limit to notes in a particular scale, like blues.  Perhaps all points repulse, but bad intervals repulse more.  Perhaps influence of an interval is increased by making the radius larger when something is close.  Seems like there would need to be much more to this.  How is trance music created?
 
 Should I normalize the global sonance function?
 
 Seems like notes should have color so can tell when the notes change.  But lines are drawn between two notes.  There are 21 different note pairs.  Maybe those have colors.  Maybe fine to average hue.  Though seems good to change color based on interval too. Maybe saturation based on pair sonance, intensity based on distance, and hue based on average note.  Radius based on global sonance.  Repulsion/attraction based on pair sonance (and possibly product of global sonance).
 
 Start with none overlapping.  Small fixed velocity.
 
 Short fadeout time.
 
 Save actual frequencies.  Some calcs done after taking log?
 
 openal
 
 volume of any point not within radius of any other is zero
 
 volume of any point coincident with another is max
 
 Volume is adjusted down by global sonance
 
 The color could be based on the sonance ranging from consonance to dissonance (Frequency ratios: ratios of higher simple numbers are more dissonant than lower ones (Pythagoras)).  The intensity could be based on the loudness which is based on distance.
 
 Perhaps there's a global sonance number for each point that is based on intensity*sonance of each other point.  Maybe each point has a volume which is considered when calculating the volume of the interval.  Intervals don't have a volume. But proximity has to figure into this.
 
 If did something like voice leading, would have triplets of notes and then one would drop out as another was added.  Points could also add harmonics which would affect the timbre and not the chord structure.  Can't really do proximity unless it was proximity to a fixed point.  Or some other global effect.  As an interval grows strong, others must become weaker.
 
 Chords emerge out of a sound cloud of various intervals.  If a C and E are close, then that reduces the repulsion between C and E and also (but to a lesser extent) between C/G, E/G, A/C, A/E, etc.  It should also increase intervals between, say, B and anything else.  If the key was C major, then there would be 21 intervals to update.
 
 I don't think repulsion should be a local only effect.  The universe determines what pairs will work.  Global sonance should figure in to repulsion as well as volume.
 
 I think repulsion should not be limited to radius.  But it would be faster, so maybe we should start with that and see how it works.
 
 Need to find common factors between numerator and denominator to correctly determine sonance
 
 while b != 0
    if a < b
        a -= b
    else
        b -= a
 return a
 
 then divide both a and b by result
 
 When nothing is playing, what is the sonance for each note?  They should all be the same.  Is it high, low or middle?  low sonance should be approaching 0.  High sonance should be 1.  Since it kind of doesn't matter, maybe I should see how the math works out and pick something easy or natural that results from the math.
 
 Sonance is 1/denominator.  Ratio is always bigger/smaller
 
 Global sonance is sum of all pair sonance weighted by sum of values normalized for the other.  That is the volume, which is that the sum of all the notes can't be greater than 1.  But don't want everything to be 1.  Base on maximum non-normalized.
 
 What are the essential parameters and how are they calculated?
    radius - global sonance * f(area)
    hue - average note
    saturation - pair sonance
    value - normalized distance
    mass - let them all be 1 for now
    force - 1 / (pair sonance * global sonance)
 
 What are the new parameters
    octave 1 - 6
    pitch numerator
    pitch denominator (or class to represent pitch)
    global sonance
    volume
 
 try a/b and b/a and use the lower sonance of the two.  So don't worry about which is higher.  Factor in octave.
 
 Start everyone with low fixed velocity.
 
 global sonace should be 0 is bad and 1 is good.
 
 force should be repulsive for anything worse than a major third (1/4) and attractive for anything better.  force should be repulsive if either has a bad global sonance and attractive if both have a good global sonance. Force should be proportional to 1/d^2
 
 Sonance has to go from -1 to 1 so that global sonance works right with volume.  Basis function for sonance goes from 1 to inf.  1->1, inf->-1, 4->0.  2/f-1 gives neutral at 2.  2/sqrt(f)-1 will work
 
 force equation is now wrong as two bad global sonances equal a good one. if any of the sonances are bad, reject.  Maybe take the min of the three.
 
 What are the final formulas?
    volume - the sum of the distance factors.  For now, max of 1
    pair sonance - 2/sqrt(f)-1 where f is simplified denominator of 2^b.octave*b.numerator*a.denominator, 2^a.octave*a.numerator*b.denominator. goes from -1 to 1
    global sonance - sum over all pairs of other.volume*sonance(other).  For now, not normalized
    force - -1/d^2*(a.global sonance+b.global sonance+pair sonance)*constant and only applied if overlapping
    radius - min radius + global sonance * radius per sonance factor
    individual hue - 2^octave*numerator/denominator normalized to 255 max
    pair hue - relative velocity
    pair saturation - 255 
    pair value - 1 - distance factor * 255 or distance factor * 255 based on pair sonance
    pair alpha - function of pair sonance and distance factor
 
 I think I'm ready to do this!
 
 */

#import "Musical.h"
#import "Processing.h"

static double REST_RADIUS_PER_SQRT_AREA = 0.06;
static double INITIAL_VELOCITY_PER_SQRT_AREA = 0.00025;
static double MAX_VELOCITY_PER_SQRT_AREA = 0.001;
static double FORCE_CONSTANT_PER_AREA = .0000000125;
static double REPULSIVE_FORCE_CONSTANT_PER_AREA_SQUARED = 0.0000002;
static double MIN_RADIUS_PER_SQRT_AREA = .00125;
static double maxVelocity;
static double restRadius;
static double forceConstant;
static double repulsiveForceConstant;
static double initialVelocity;
static double minRadius;
static int frameNumber = 0;
static double minPitch;
static double maxPitch;
static int minOctave = 1;
static int maxOctave = 7;

static int pitchNumerators[] = {1,9,5,4,3,5,15};
static int pitchDenominators[] = {1,8,4,3,2,3,8};

@implementation Musical
+(void)createInstances {
    int area = width*height;
    restRadius = sqrt(area)*REST_RADIUS_PER_SQRT_AREA;
    forceConstant = area*FORCE_CONSTANT_PER_AREA;
    repulsiveForceConstant = pow(area,2)*REPULSIVE_FORCE_CONSTANT_PER_AREA_SQUARED;
    maxVelocity = sqrt(area)*MAX_VELOCITY_PER_SQRT_AREA;
    initialVelocity = sqrt(area)*INITIAL_VELOCITY_PER_SQRT_AREA;
    minRadius = sqrt(area)*MIN_RADIUS_PER_SQRT_AREA;
    minPitch = pow(2,minOctave)*pitchNumerators[0]/pitchDenominators[0];
    maxPitch = pow(2,maxOctave)*pitchNumerators[6]/pitchDenominators[6];
    for (int i = 0;i < 1;i++) {
        for (int j = minOctave; j <= maxOctave;j++) {
            for (int k = 0;k < 7;k++) {
                [self addObject:[[Musical alloc] initWithOctave:j numerator:pitchNumerators[k] denominator:pitchDenominators[k]]];
            }
            
        }
    }
}

double calcConsonance(double sonance1, double sonance2, double sonance3) {
    double consonance = sonance1;
    if (consonance > sonance2) {
        consonance = sonance2;
    }
    if (consonance > sonance3) {
        consonance = sonance3;
    }
    return consonance;
}

+(void)update {
    NSMutableArray* elements = [self elements];
    // initialize - for every element, set volume and global sonance to 0
    for (int i = 0; i < [elements count]; i++) {
        Musical* element = [elements objectAtIndex:i];
        element->volume = 0;
        element->globalSonance = 0;
    }
    // calculate volume - for every pair that overlaps, increment volume to max of 1
    for (int i = 0; i < [elements count] - 1; i++) {
        Musical* element1 = [elements objectAtIndex:i];
        for (int j = i+1; j < [elements count]; j++) {
            Musical* element2 = [elements objectAtIndex:j];
            double xDiff = element1->x - element2->x;
            double yDiff = element1->y - element2->y;
            double d2 = xDiff*xDiff + yDiff*yDiff;
            if (d2 < (element1->radius + element2->radius)*(element1->radius + element2->radius)) {
                double d = sqrt(d2);
                double distanceFactor = 1.0 - d/(element1->radius + element2->radius);
                element1->volume += distanceFactor;
                element2->volume += distanceFactor;
                if (element1->volume > 1.0) {
                    element1->volume = 1.0;
                }
                if (element2->volume > 1.0) {
                    element2->volume = 1.0;
                }
            }
        }
    }
    // calculate global sonance - for every element, go through all other elements that have a non zero volume and increment global sonance
    for (int i = 0; i < [elements count]; i++) {
        Musical* element1 = [elements objectAtIndex:i];
        for (int j = 0; j < [elements count]; j++) {
            if (j == i) {
                continue;
            }
            Musical* element2 = [elements objectAtIndex:j];
            if (element2->volume == 0.0) {
                continue;
            }
            element1->globalSonance += [element1 calcSonance: element2]*element2->volume;
        }
    }
    // limit global sonance
    for (int i = 0; i < [elements count]; i++) {
        Musical* element = [elements objectAtIndex:i];
        if (element->globalSonance > 1.0) {
            element->globalSonance = 1.0;
        }
        else if (element->globalSonance < -1.0) {
            element->globalSonance = -1.0;
        }
    }
    // calculate velocities
    for (int i = 0; i < [elements count] - 1; i++) {
        Musical* element1 = [elements objectAtIndex:i];
        for (int j = i+1; j < [elements count]; j++) {
            Musical* element2 = [elements objectAtIndex:j];
            int widthOffset;
            int heightOffset;
            double d2;
            if ([element1 touching: element2 ThresholdMultiplier: 2.0 DistanceSquared:&d2 WidthOffset:&widthOffset HeightOffset:&heightOffset] && d2 > 0.1) {
                double d = sqrt(d2);
                double pairSonance = [element1 calcSonance: element2];
                double force = -1.0/d*calcConsonance(element1->globalSonance, element2->globalSonance, pairSonance)*forceConstant*element1->mass*element2->mass;
                force += 1.0/(d2*d2)*repulsiveForceConstant;
                [element1 updateVelocityUsingElement:element2 Force:force Distance:d WidthOffset:widthOffset HeightOffset:heightOffset];
                [element2 updateVelocityUsingElement:element1 Force:force Distance:d WidthOffset:-widthOffset HeightOffset:-heightOffset];
            }
        }
    }
    // move
    for (int i = 0; i < [elements count]; i++) {
        Musical* element = [elements objectAtIndex:i];
        element->lastX = element->x;
        element->lastY = element->y;
        element->x += element->dx;
        element->y += element->dy;
        if (element->x > width) {
            element->x = element->x - width;
        }
        else if (element->x < 0) {
            element->x = element->x + width;
        }
        if (element->y > height) {
            element->y = element->y - height;
        }
        else if (element->y < 0) {
            element->y = element->y + height;
        }
    }
}

-(void)updateVelocityUsingElement: (Element*) other Force: (double) force Distance: (double) d WidthOffset: (int) widthOffset HeightOffset: (int) heightOffset {
    double xDiff = x - other->x - widthOffset;
    double yDiff = y - other->y - heightOffset;
    double acceleration = force/mass;
    double dxTemp = dx + xDiff/d*acceleration;
    double dyTemp = dy + yDiff/d*acceleration;
    double velocityTemp = sqrt(dxTemp*dxTemp+dyTemp*dyTemp);
    if (velocityTemp < maxVelocity) {
        dx = dxTemp;
        dy = dyTemp;
        velocity = velocityTemp;
        mass = restMass/sqrt(1-velocity*velocity/(maxVelocity*maxVelocity));
        radius = restRadius*(globalSonance+1)/2 + minRadius;
    }
    
}

double normalizedPitch(Musical* element) {
    return ((double)element->pitchNumerator/element->pitchDenominator-1.0)/(7.0/8.0);
    //return (pow(2,element->pitchOctave)*element->pitchNumerator/element->pitchDenominator-minPitch)/(maxPitch-minPitch);
}

-(void)draw:(Musical*)other WidthOffset: (int) widthOffset HeightOffset: (int) heightOffset Distance:(double) distance {
    double h1 = normalizedPitch(self)*255/2+10;
    double h2 = normalizedPitch(other)*255/2+10;
    double distanceFactor = distance/(radius + other->radius);
    //double h = (h1 + h2)/2;
    double pairSonance = [self calcSonance:other];
    double consonance = calcConsonance(globalSonance, other->globalSonance, pairSonance);
    consonance = consonance/2+.5f;
    
    strokeHSB(h1,255,(1-distanceFactor)*255,consonance*255/4);
    line(x, y, other->x + widthOffset, other->y + heightOffset);
    strokeHSB(h2,255,(1-distanceFactor)*255,consonance*255/4);
    line(x+1, y+1, other->x+1+widthOffset, other->y+1+heightOffset);
}
+(void)draw {
    frameNumber++;
    if (frameNumber == 300) {
        fillHSB(0.0f, 0.0f, 0.0f, 0.5f);
        background();
        frameNumber = 0;
    }
    NSMutableArray* elements = [self elements];
    strokeWeight(0.5f);
    for (int i = 0; i < [elements count] - 1; i++) {
        // Get a first element
        Musical* element1 = [elements objectAtIndex:i];
        //double h = element1->velocity/maxVelocity*255;
        //strokeHSB(0,0,h,150);
        //line(element1->lastX, element1->lastY, element1->x, element1->y);
        //strokeHSB(0, 0, 255, 255);
        //point(element1->x, element1->y);
        //strokeHSB(0, 0, 0, 255);
        //point(element1->lastX, element1->lastY);
        //point(element2->lastX, element2->lastY);
        //strokeHSB(0, 0, 100, 100);
        //circle(element1->x, element1->y, element1->radius);
        //double velocityFactor = element1->velocity/maxVelocity*100+50;
        //strokeHSB(0, 0, velocityFactor, velocityFactor);
        //circle(element1->x, element1->y, element1->radius*sqrt(2.0));
        for (int j = i+1; j < [elements count]; j++) {
            // Get a second element
            Musical* element2 = [elements objectAtIndex:j];
            // If the elements are touching
            double d2;
            int widthOffset;
            int heightOffset;
            if ([element1 touching: element2 ThresholdMultiplier: 1.0 DistanceSquared:&d2 WidthOffset:&widthOffset HeightOffset:&heightOffset]) {
                double d = sqrt(d2);
                if (widthOffset == 0 && heightOffset == 0) {
                    [element1 draw:element2 WidthOffset: 0 HeightOffset: 0 Distance: d];
                }
                else if (widthOffset == 0) {
                    [element1 draw:element2 WidthOffset: 0 HeightOffset: heightOffset Distance: d];
                    [element2 draw:element1 WidthOffset: 0 HeightOffset: -heightOffset Distance: d];
                }
                else if (heightOffset == 0) {
                    [element1 draw:element2 WidthOffset: widthOffset HeightOffset: 0 Distance: d];
                    [element2 draw:element1 WidthOffset: -widthOffset HeightOffset: 0 Distance: d];
                }
                else {
                    [element1 draw:element2 WidthOffset: widthOffset HeightOffset: heightOffset Distance: d];
                    [element2 draw:element1 WidthOffset: -widthOffset HeightOffset: -heightOffset Distance: d];
                }
            }
        }
    }
}

-(id)initWithOctave: (int) octave numerator: (int) numerator denominator: (int) denominator {
    self = [super init];
    if (self) {
        radius = restRadius + minRadius;
        pitchOctave = octave;
        pitchNumerator = numerator;
        pitchDenominator = denominator;
        x = randomMax(width*1.02f) - width*0.01f;
        y = randomMax(height*1.02f) - height*0.01f;
        while ([self touching]) {
            x = randomMax(width*1.02f) - width*0.01f;
            y = randomMax(height*1.02f) - height*0.01f;
        }
        velocity = initialVelocity;
        restMass = 5.0f;
        mass = restMass;
        heading = randomMax(TWO_PI);
        speed = velocity;
        dx = sinf(heading)*speed;
        dy = cosf(heading)*speed;
    }
    return self;
}

int gcf(int a, int b) {
    while (b != 0) {
        if (a > b) {
            a -= b;
        }
        else {
            b -= a;
        }
    }
    return a;
}

-(double)calcSonance: (Musical*)other {
    Musical* low = self;
    Musical* high = other;
    if (low->pitchOctave > high->pitchOctave || (low->pitchOctave == high->pitchOctave && (low->pitchNumerator/low->pitchDenominator > high->pitchNumerator/high->pitchDenominator))) {
        low = other;
        high = self;
    }
    int intervalNumerator = pow(2.0f,high->pitchOctave)*high->pitchNumerator*low->pitchDenominator;
    int intervalDenominator = pow(2.0f,low->pitchOctave)*low->pitchNumerator*high->pitchDenominator;
    int commonFactor = gcf(intervalNumerator, intervalDenominator);
    intervalNumerator = intervalNumerator/commonFactor;
    intervalDenominator = intervalDenominator/commonFactor;
    return 2/sqrt(intervalDenominator)-1.0;
}

double d2(Element* a, Element* b, int widthOffset, int heightOffset) {
    double xDiff = a->x - b->x - widthOffset;
    double yDiff = a->y - b->y - heightOffset;
    return xDiff*xDiff + yDiff*yDiff;
}

-(Boolean)touching: (Element*) other ThresholdMultiplier: (double) thresholdMultiplier DistanceSquared: (double*) distanceSquared WidthOffset: (int*) widthOffset HeightOffset: (int*) heightOffset {
    float threshold = thresholdMultiplier*(radius + other->radius)*(radius + other->radius);
    *widthOffset = 0;
    *heightOffset = 0;
    *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
    if (*distanceSquared < threshold) {
        return true;
    } else {
        double d = sqrt(*distanceSquared);
        // is it possible that the two points are close if wrapped around?
        if ((x > width-d && other->x < x-width+d) ||
            (x < d && other->x > width-d+x) ||
            (y > height-d && other->y < y-height+d) ||
            (y < d && other->y > height-d+y)) {
            // check corner to opposite corner
            if (x > width-d && y > height-d) {
                *widthOffset = width;
                *heightOffset = height;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            else if (x > width-d && y < d) {
                *widthOffset = width;
                *heightOffset = -height;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            else if (x < d && y > height-d) {
                *widthOffset = -width;
                *heightOffset = height;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            else if (x < d && y < d) {
                *widthOffset = width;
                *heightOffset = height;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            // check left/right
            if (x > width-d) {
                *widthOffset = width;
                *heightOffset = 0;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            else if (x < d) {
                *widthOffset = -width;
                *heightOffset = 0;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            // check top/bottom
            if (y > height-d) {
                *widthOffset = 0;
                *heightOffset = height;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
            else if (y < d) {
                *widthOffset = 0;
                *heightOffset = -height;
                *distanceSquared = d2(self, other, *widthOffset, *heightOffset);
                if (*distanceSquared < threshold) {
                    return true;
                }
            }
        }
    }
    return false;
}


@end

