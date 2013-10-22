//
//  Relativity.h
//  Jessa
//
//  Created by Rick Rothenberg on 6/1/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"

@interface Relativity2 : Element {
    float dx;
    float dy;
    float mass;
    float restMass;
    float velocity;
    float lastX;
    float lastY;
}
+(void)update;
+(void)createInstances;
-(void)updateVelocityUsingElement: (Element*) other Force: (float) force Distance: (float) distance;
-(void)initialize;
//-(void)draw:(Element*)other;
//+(void)draw;
//-(void)behavior2;
@end
