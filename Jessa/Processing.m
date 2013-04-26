//
//  Processing.m
//  Jessa
//
//  Created by Rick Rothenberg on 3/27/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Processing.common.h"
#import <ScreenSaver/ScreenSaver.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreGraphics/CoreGraphics.h>

int width;
int height;

static float strokeWeightValue = 0.5;

float randomMax(float upperLimit) {
    return randomRange(0.0, upperLimit);
}

float randomRange(float lowerLimit, float upperLimit) {
    return SSRandomFloatBetween(lowerLimit, upperLimit);
}

int randomIntMax(int upperLimit) {
    return SSRandomIntBetween(0, upperLimit);
}

void background(float gray) {
    
}

void strokeWeight(float weight) {
    strokeWeightValue = weight;
}

void stroke(float r, float g, float b, float alpha) {
    NSColor *color = [NSColor colorWithCalibratedRed:r/255 green:g/255 blue:b/255 alpha:alpha/255];
    [color set];
}

void strokeHSB(float h, float s, float b, float alpha) {
    NSColor *color = [NSColor colorWithCalibratedHue:h/255 saturation:s/255 brightness:b/255 alpha:alpha/255];
    [color set];
}

void line(float x1, float y1, float x2, float y2) {
    NSGraphicsContext* nsGraphicsContext = [NSGraphicsContext currentContext];
    CGContextRef c = (CGContextRef) [nsGraphicsContext graphicsPort];
    CGContextSetLineWidth(c, strokeWeightValue);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x1, y1);
    CGContextAddLineToPoint(c, x2, y2);
    CGContextStrokePath(c);
}

void point(float x, float y) {
    line(x, y, x+1, y+1);
    line(x+1, y, x, y+1);
}

float dist(float x1, float y1, float x2, float y2) {
    return sqrtf((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2));
}

void initializeProcessing(int _width, int _height) {
    width = _width;
    height = _height;
}

