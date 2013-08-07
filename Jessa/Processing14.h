//
//  Processing14.h
//  Jessa
//
//  Created by Rick Rothenberg on 5/3/13.
//  Copyright (c) 2013 Rick Rothenberg. All rights reserved.
//

#import "Element.h"

@interface Processing14 : Element {
    float h;
}
-(void)initialize;
+(void)createInstances;
-(void)draw:(Element*)other;
+(int)numberFramesPerFade;
@end
