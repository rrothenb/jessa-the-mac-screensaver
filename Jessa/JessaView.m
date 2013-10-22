 //
//  JessaView.m
//  Jessa
//
//  Created by Rick Rothenberg on 3/20/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "JessaView.h"
#import "Processing.h"
#import "Processing4.h"
#import "Processing6.h"
#import "Lissajous1.h"
#import "Processing14.h"
#import "Relativity.h"
#import "Minimal.h"
#import "Musical.h"
#import "Relativity2.h"
#import "Relativity3.h"

typedef enum {
    processing4,
    processing6,
    lissajous1,
    processing14,
    relativity,
    minimal,
    musical,
    relativity2,
    relativity3
} Algorithm;

static Class current;

@implementation JessaView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
    Algorithm algorithm = randomIntMax(relativity3);
    algorithm = musical;
    if (algorithm == processing4) {
        current = [Processing4 class];
    }
    else if (algorithm == musical) {
        current = [Musical class];
    }
    else if (algorithm == processing6) {
        current = [Processing6 class];
    }
    else if (algorithm == lissajous1) {
        current = [Lissajous1 class];
    }
    else if (algorithm == processing14) {
        current = [Processing14 class];
    }
    else if (algorithm == relativity){
        current = [Relativity class];
    }
    else if (algorithm == relativity2){
        current = [Relativity2 class];
    }
    else if (algorithm == relativity3){
        current = [Relativity3 class];
    }
    else {
        current = [Minimal class];
    }
    [current initializeWithView:self];
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    [current update]; // Update all of the elements
    [current draw];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
