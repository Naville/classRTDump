//
//  Dumper.m
//  
//
//  Created by Zhang Naville on 23/12/2015.
//
//

#import "Dumper.h"
//OBJC_EXPORT struct objc_method_description *method_getDescription(Method m) __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0);

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
        NSMutableDictionary* InfoDict=[NSMutableDictionary dictionary];
        [InfoDict addEntriesFromDictionary:[self methodsForClass:currentClassName]];
         [InfoDict addEntriesFromDictionary:[self propertiesForClass:currentClassName]];
         [InfoDict addEntriesFromDictionary:[self ivarForClass:currentClassName]];
        
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
-(NSMutableDictionary*)propertiesForClass:(NSString*)className{
    NSMutableDictionary* returnDictionary=[NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(objc_getClass(className.UTF8String), &count);
    for (int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        unsigned int attributecount;
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        objc_property_attribute_t *attributes=property_copyAttributeList(property,&attributecount);
        NSMutableString* attriCombinedString=[NSMutableString string];
        for(int j=0;j<attributecount;j++){
            objc_property_attribute_t attr=attributes[j];
            NSString* attriString=[NSString stringWithUTF8String:attr.name];
            [attriCombinedString appendString:attriString];
            
            
        }
        free(attributes);
        [returnDictionary setObject:attriCombinedString forKey:name];
    }
    
    free(properties);
    NSLog(@"%@",returnDictionary);
    return returnDictionary;
}
-(NSMutableDictionary*)ivarForClass:(NSString*)className{
    NSMutableDictionary* returnDict=[NSMutableDictionary dictionary];
    unsigned int count;
    Ivar * IvarList=class_copyIvarList(objc_getClass(className.UTF8String), &count);
    for(int i=0;i<count;i++){
        Ivar currentIvar=IvarList[i];
        NSDictionary* ivarInfoDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:ivar_getName(currentIvar)],@"Name", [NSString stringWithUTF8String:ivar_getOffset(currentIvar)],@"Offset",[NSString stringWithUTF8String:ivar_getTypeEncoding(currentIvar)],@"TypeEncoding",nil];
        [returnDict setObject:ivarInfoDict forKey:[NSString stringWithUTF8String:ivar_getName(currentIvar)]];
        
        
        
    }
    
    return returnDict;
}
-(NSMutableDictionary*)protocalForClass:(NSString*)className{
    NSMutableDictionary* ReturnDict=[NSMutableDictionary dictionary];
    NSMutableArray* protoList=[NSMutableArray array];
    unsigned int count;
    Protocol **protocalList=class_copyProtocolList(objc_getClass(className.UTF8String), &count);
    for(int i=0;i<count;i++){
        NSString* protoName=[NSString stringWithUTF8String:protocol_getName(protocalList[i])];
        [protoList addObject:protoName];
        
    }
    
    [ReturnDict setObject:protoList forKey:@"Protocal"];
    return ReturnDict;
}
@end
