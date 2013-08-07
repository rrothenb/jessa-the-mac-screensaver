//
//  Lissajous1.h
//  Jessa
//
//  Created by Rick Rothenberg on 4/20/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"

@interface Lissajous1 : Element {
    float f1;
    float f2;
    
    float t;
    float dt;
    
    float h;
    
    float lastX;
    float lastY;
}
-(id)initWithF1: (int) _f1 f2: (int) _f2 dt: (float) _dt;
+(void)createInstances;
-(void)update;
-(void)draw:(Element*)other;

@end
