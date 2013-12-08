//
//  Sound.c
//  Jessa
//
//  Created by Rick Rothenberg on 11/16/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#include <stdio.h>
#include "Sound.h"
#include <CoreFoundation/CoreFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <asl.h>

#define NUM_VOICES 24
#define NUM_BUFFERS_PER_VOICE 25
#define NUM_BUFFERS NUM_BUFFERS_PER_VOICE*NUM_VOICES
#define LOWEST_NOTE 27.5

#define NEVER_USED 0
#define IDLE 1
#define ACTIVE 2

#define PI 3.1415926535897932384

static ALCdevice* device;
static ALCcontext* context;
static uint voices[NUM_VOICES];
static uint buffers[NUM_BUFFERS];
static int currentBuffer[NUM_VOICES];
static bool allocated[NUM_VOICES];
static int state[NUM_VOICES];
static float phase[NUM_VOICES];
static float volumes[NUM_VOICES];
static float totalVolume;
static ALenum error;
static int freeVoices;
static aslclient logger;
static int numberAllocationAttempts;
static int numberFailedAllocations;
static int lastSample[NUM_VOICES];
static int maxChange;
static double minPitch;
static double maxPitch;

double aWeighting(double f) {
    return 12200*12200*pow(f,4)/((f*f+20.6*20.6)*(f*f+12200*12200)*sqrt((f*f+107.7*107.7)*(f*f+737.9*737.9)));
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
typedef OSStatus	(*alcASASetSourceProcPtr)	(const ALuint property, ALuint source, ALvoid *data, ALuint dataSize);
OSStatus  alcASASetSourceProc(const ALuint property, ALuint source, ALvoid *data, ALuint dataSize)
{
    OSStatus	err = noErr;
	static	alcASASetSourceProcPtr	proc = NULL;
    
    if (proc == NULL) {
        proc = (alcASASetSourceProcPtr) alcGetProcAddress(NULL, (const ALCchar*) "alcASASetSource");
    }
    
    if (proc)
        err = proc(property, source, data, dataSize);
    return (err);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
typedef OSStatus	(*alcASASetListenerProcPtr)	(const ALuint property, ALvoid *data, ALuint dataSize);
OSStatus  alcASASetListenerProc(const ALuint property, ALvoid *data, ALuint dataSize)
{
    OSStatus	err = noErr;
	static	alcASASetListenerProcPtr	proc = NULL;
    
    if (proc == NULL) {
        proc = (alcASASetListenerProcPtr) alcGetProcAddress(NULL, "alcASASetListener");
    }
    
    if (proc)
        err = proc(property, data, dataSize);
    return (err);
}

void checkForErrors(char* action) {
    if ((error = alGetError()) != AL_NO_ERROR) {
        if (error == AL_INVALID_ENUM) {
            asl_log(logger, NULL, ASL_LEVEL_ALERT, "%s error: %x - AL_INVALID_ENUM", action, error);
        }
        else if (error == AL_INVALID_NAME) {
            asl_log(logger, NULL, ASL_LEVEL_ALERT, "%s error: %x - AL_INVALID_NAME", action, error);
        }
        else if (error == AL_INVALID_OPERATION) {
            asl_log(logger, NULL, ASL_LEVEL_ALERT, "%s error: %x - AL_INVALID_OPERATION", action, error);
        }
        else if (error == AL_INVALID_VALUE) {
            asl_log(logger, NULL, ASL_LEVEL_ALERT, "%s error: %x - AL_INVALID_VALUE", action, error);
        }
        else {
            asl_log(logger, NULL, ASL_LEVEL_ALERT, "%s error: %x - %i", action, error, error);
        }
        return;
    }
}


void initSound(int width, int height, double minPitchVal, double maxPitchVal) {
    minPitch = minPitchVal;
    maxPitch = maxPitchVal;
    logger = asl_open("Jessa", "Screensaver", ASL_OPT_STDERR);
    asl_log(logger, NULL, ASL_LEVEL_ALERT, "initing sounds");
    alGetError();
    device = alcOpenDevice(NULL);
    context = alcCreateContext(device, NULL);
    alcMakeContextCurrent(context);
    checkForErrors("current context");
    alGenBuffers(NUM_BUFFERS, buffers);
    checkForErrors("gen buffers");
    alGenSources(NUM_VOICES, voices);
    checkForErrors("gen sources");
    float position[]={width/2.0,height,2.0,width/4.0};
    alListenerfv(AL_POSITION, position);
    checkForErrors("listener position");
    alListenerf(AL_GAIN, 0.75);
    checkForErrors("listener gain");
    alDopplerFactor(0.5);
    checkForErrors("doppler factor");
    if (alcIsExtensionPresent( NULL, "ALC_EXT_ASA" )) {
        asl_log(logger, NULL, ASL_LEVEL_ALERT, "initing reverb");
        uint setting = 1;
        alcASASetListenerProc(alcGetEnumValue(NULL, "ALC_ASA_REVERB_ON"), &setting, sizeof(setting));
        checkForErrors("reverb on");
        float level = 1.0;
        alcASASetListenerProc(alcGetEnumValue(NULL, "ALC_ASA_REVERB_GLOBAL_LEVEL"), &level, sizeof(level));
        checkForErrors("reverb global level");
        setting = 8; // cathedral
		alcASASetListenerProc(alcGetEnumValue(NULL, "ALC_ASA_REVERB_ROOM_TYPE"), &setting, sizeof(setting));
        checkForErrors("reverb room type");
    }
    checkForErrors("check for extension");

    //alDistanceModel(AL_NONE);
    //checkForErrors("distance model");
    for (int i = 0;i<NUM_VOICES;i++ ) {
        allocated[i] = FALSE;
        state[i] = NEVER_USED;
        phase[i] = 0.0;
        lastSample[i] = 0;
        currentBuffer[i] = -1;
        volumes[i] = 0.0;
        alSourcei(voices[i], AL_LOOPING, AL_FALSE);
        checkForErrors("looping");
        alSourcef(voices[i], AL_REFERENCE_DISTANCE, 500.0);
        checkForErrors("reference distance");
        alSourcef(voices[i], AL_GAIN, 0.75);
        checkForErrors("source gain");
        float level = 1.0;
        alcASASetSourceProc(alcGetEnumValue(NULL, "ALC_ASA_REVERB_SEND_LEVEL"), voices[i], &level, sizeof(level));
        checkForErrors("reverb source level");
    }
    freeVoices = NUM_VOICES;
    numberAllocationAttempts = 0;
    numberFailedAllocations = 0;
    maxChange = 0;
    totalVolume = 0.0;
}

int allocateSound() {
    numberAllocationAttempts++;
    if (freeVoices == 0) {
        numberFailedAllocations++;
        //asl_log(logger, NULL, ASL_LEVEL_ALERT, "percent failed to allocate sound: %f", 100.0f*numberFailedAllocations/numberAllocationAttempts);
        return -1;
    }
    for (int i=0;i<NUM_VOICES;i++) {
        if (!allocated[i]) {
            int sourceState;
            alGetSourcei(voices[i], AL_SOURCE_STATE, &sourceState);
            checkForErrors("source state");
            if (sourceState != AL_PLAYING) {
                allocated[i] = TRUE;
                phase[i] = 0.0;
                freeVoices--;
                return i;
            }
        }
    }
    numberFailedAllocations++;
    asl_log(logger, NULL, ASL_LEVEL_ALERT, "percent failed to allocate sound: %f (%i still busy)", 100.0f*numberFailedAllocations/numberAllocationAttempts, freeVoices);
    return -1;
}

void releaseSound(int id) {
    if (id == -1) {
        return;
    }
    allocated[id] = FALSE;
    state[id] = IDLE;
    freeVoices++;
}

void shutdownSound() {
    
}

void updateSound(int id, double frequency, double volume, double x, double y, double dx, double dy, double globalSonance, double velocityFactor) {
    if (id == -1) {
        return;
    }
    totalVolume = totalVolume - volumes[id] + volume;
    volumes[id] = volume;
    int numFreeBuffers;
    uint buffersRemoved[NUM_BUFFERS_PER_VOICE];
    if (state[id] == NEVER_USED) {
        numFreeBuffers = NUM_BUFFERS_PER_VOICE;
    }
    else {
        alGetSourcei(voices[id], AL_BUFFERS_PROCESSED, &numFreeBuffers);
        checkForErrors("buffers processed");
        alSourceUnqueueBuffers(voices[id], numFreeBuffers, buffersRemoved);
        checkForErrors("unqueue buffer data");
    }
    float p = phase[id];
    for (int n=0;n<numFreeBuffers;n++) {
        int16_t buffer[480];
        for (int i=0;i<480;i++) {
            double t = frequency*LOWEST_NOTE*p;
            double a = globalSonance/2+.5;
            double b = volume*(frequency-minPitch)/(maxPitch-minPitch);
            double c = velocityFactor;
            double sample = sin(t+a*sin(t+b*c*sin(5*t))+b*sin(2*t+a*c*sin(4*t))+c*sin(3*t+a*b*sin(3*t)));
            sample = round(sample*INT16_MAX*volume*0.025/aWeighting(frequency*LOWEST_NOTE));
            if (sample < INT16_MIN || sample > INT16_MAX) {
                asl_log(logger, NULL, ASL_LEVEL_ALERT, "CRAP!  voulme is %f and weight is %f", volume, 0.025/aWeighting(frequency*LOWEST_NOTE));
            }
            buffer[i] = sample;
            if (state[id] == IDLE && n == 0) {
                buffer[i] = buffer[i] * i/480.0;
            }
            int change = abs(buffer[i] - lastSample[id]);
            if (change > maxChange) {
                maxChange = change;
                asl_log(logger, NULL, ASL_LEVEL_ALERT, "max change %i", maxChange);
                asl_log(logger, NULL, ASL_LEVEL_ALERT, "while playing %i with frequency %f, volume %f, velocityFactor %f, and global sonance %f ", id, frequency*LOWEST_NOTE, volume, velocityFactor, globalSonance);
            }
            lastSample[id] = buffer[i];
            p = p + 1/48000.0;
        }
        currentBuffer[id] = (currentBuffer[id]+1)%NUM_BUFFERS_PER_VOICE;
        alBufferData(buffers[id*NUM_BUFFERS_PER_VOICE+currentBuffer[id]], AL_FORMAT_MONO16, buffer, 480*2, 48000);
        checkForErrors("set buffer data");
        alSourceQueueBuffers(voices[id], 1, &buffers[id*NUM_BUFFERS_PER_VOICE+currentBuffer[id]]);
        checkForErrors("queue buffer data");
    }
    while (frequency*LOWEST_NOTE*p > 2*PI) {
        p = p - 2*PI/(frequency*LOWEST_NOTE);
    }
    phase[id] = p;
    float position[]={x,y,0};
    alSourcefv(voices[id], AL_POSITION, position);
    checkForErrors("source position");
    float velocity[]={dx,dy,0};
    alSourcefv(voices[id], AL_VELOCITY, velocity);
    checkForErrors("source velocity");
    int sourceState;
    alGetSourcei(voices[id], AL_SOURCE_STATE, &sourceState);
    checkForErrors("source state");
    if (sourceState != AL_PLAYING) {
        if (state[id] == ACTIVE) {
            asl_log(logger, NULL, ASL_LEVEL_ALERT, "restarting to play %i", id);
        }
        else {
            //asl_log(logger, NULL, ASL_LEVEL_ALERT, "initiating play of %i with frequency %f, volume %f, global sonance %f, velocity factor %f, and weight %f", id, frequency*LOWEST_NOTE, volume, globalSonance, velocityFactor, 1.0/aWeighting(frequency*LOWEST_NOTE)*0.025);
        }
        alSourcePlay(voices[id]);
    }
    state[id] = ACTIVE;
}

