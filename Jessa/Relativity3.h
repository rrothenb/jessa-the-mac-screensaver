#import "Element.h"

@interface Relativity3 : Element {
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
-(void)draw:(Element*)other;
+(void)draw;
@end
