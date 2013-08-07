//
//  Processing.common.h
//  Jessa
//
//  Created by Rick Rothenberg on 4/22/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//


float randomMax(float upperLimit);

float randomRange(float lowerLimit, float upperLimit);

int randomIntMax(int upperLimit);

void background();

void strokeWeight(float weight);

void stroke(float r, float g, float b, float alpha);

void strokeHSB(float h, float s, float b, float alpha);

void fillHSB(float h, float s, float b, float alpha);

void line(float x1, float y1, float x2, float y2);

void point(float x, float y);

float dist(float x1, float y1, float x2, float y2);

void initializeProcessing(int width, int height);

void circle(float x, float y, float radius);


#define PI 3.14159265358979323846
#define TWO_PI 2*PI

