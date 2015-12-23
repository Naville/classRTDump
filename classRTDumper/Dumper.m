//
//  Dumper.m
//  
//
//  Created by Zhang Naville on 23/12/2015.
//
//

#import "Dumper.h"

@implementation Dumper{
    NSArray* classList;
    NSMutableArray* dumpedClasses;
}
+(id)dumper{
    return [[self alloc] init];
}
-(void)setupWithList:(NSArray*)List{
    self->classList=[NSMutableArray arrayWithArray:List];
    self->dumpedClasses=[NSMutableArray array];
    
}
-(void)startDump{
    for(int x=0;x<classList.count;x++){
        NSString* currentClassName=[classList objectAtIndex:x];
        NSMutableDictionary* methodList=[self methodsForClass:currentClassName];
        
    }
}
-(NSMutableDictionary*)methodsForClass:(NSString*)className{
    NSMutableDictionary* returnDictionary=[NSMutableDictionary dictionary];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(objc_getClass(className.UTF8String), &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString* methodName=[NSString stringWithFormat:@"%s",sel_getName(method_getName(method))];
        NSString* TypeEncoding=[NSString stringWithFormat:@"%s",method_getTypeEncoding(method)];
        [returnDictionary setObject:TypeEncoding forKey:methodName];
    }
    free(methods);
    Method *methods2 = class_copyMethodList(objc_getMetaClass(className.UTF8String), &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods2[i];
        NSString* methodName=[NSString stringWithFormat:@"%s",sel_getName(method_getName(method))];
        NSString* TypeEncoding=[NSString stringWithFormat:@"%s",method_getTypeEncoding(method)];
        [returnDictionary setObject:TypeEncoding forKey:methodName];
    }
    
    
    
    return returnDictionary;
    
}
@end
