//
//  Element.h
//  Jessa
//
//  Created by Rick Rothenberg on 3/28/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Element : NSObject {
    @public
    float x;
    float y;
    float radius;
    float speed;
    float heading;
    float rotation;
    float r;
    float g;
    float b;
}
-(void)update;
-(void)behavior1;
-(void)behavior2;
-(void)behavior3;
-(Boolean)touching:(Element*)other;
-(Boolean)touching;
+(void)initializeWithView:(NSView*) view;
+(void)createInstances;
+(void)update;
+(id)new;
-(id)init;
-(void)initialize;
+(void)addObject:(Element*) element;
-(float)distance:(Element*)other;
+(void)draw;
-(void)draw:(Element*)other;
+(NSMutableArray*) elements;
+(int)numberFramesPerFade;
@end
