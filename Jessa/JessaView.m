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

typedef enum {
    processing4,
    processing6,
    lissajous1
} Algorithm;

@implementation JessaView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/150.0];
    }
    Algorithm algorithm = randomIntMax(lissajous1);
    if (algorithm == processing4) {
        [Processing4 initializeWithView:self];
    }
    else if (algorithm == processing6) {
        [Processing6 initializeWithView:self];
    }
    else {
        [Lissajous1 initializeWithView:self];
    }
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
    [Element update]; // Update all of the elements
    [Element draw];
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
