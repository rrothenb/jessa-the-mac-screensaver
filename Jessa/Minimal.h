//
//  Minimal.h
//  Jessa
//
//  Created by Rick Rothenberg on 6/4/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"

@interface Minimal : Element {
    float h;
}
-(void)initialize;
+(void)createInstances;
-(void)draw:(Element*)other;
+(int)numberFramesPerFade;
@end
