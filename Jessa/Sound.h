//
//  Sound.h
//  Jessa
//
//  Created by Rick Rothenberg on 11/16/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#ifndef Jessa_Sound_h
#define Jessa_Sound_h

void initSound(int width, int height, double minPitch, double maxPitch);

int allocateSound();

void releaseSound(int id);

void shutdownSound();

void updateSound(int id, double frequency, double volume, double x, double y, double dx, double dy, double globalSonance, double velocityFactor);

#endif
