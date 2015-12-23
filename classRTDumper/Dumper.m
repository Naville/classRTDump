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
    NSMutableDictionary* dumpedClasses;
    NSArray* ProtocalList;
     NSMutableDictionary* dumpedProtocals;
}
+(id)dumper{
    return [[self alloc] init];
}
-(void)setupWithClassList:(NSArray*)classInputList protocalList:(NSArray*)InputprotocalList{
    self->classList=[NSMutableArray arrayWithArray:classInputList];
    self->ProtocalList=[NSMutableArray arrayWithArray:InputprotocalList];
    self->dumpedClasses=[NSMutableDictionary dictionary];
    self->dumpedProtocals=[NSMutableDictionary dictionary];
    NSLog(@"Class List Length:%lu\nProtocal List Length:%lu",(unsigned long)self->classList.count,(unsigned long)self->ProtocalList.count);
    
}
-(void)startDump{
    NSLog(@"Start Dumping Classes");
    for(int x=0;x<classList.count;x++){
        NSString* currentClassName=[classList objectAtIndex:x];
        NSMutableDictionary* InfoDict=[NSMutableDictionary dictionary];
        [InfoDict addEntriesFromDictionary:[self methodsForClass:currentClassName]];
         [InfoDict addEntriesFromDictionary:[self propertiesForClass:currentClassName]];
         [InfoDict addEntriesFromDictionary:[self ivarForClass:currentClassName]];
        [InfoDict addEntriesFromDictionary:[self protocalForClass:currentClassName]];
        [dumpedClasses setObject:InfoDict forKey:currentClassName];
        
    }
    NSLog(@"Start Dumping Protocols");
    for(int j=0;j<ProtocalList.count;j++){
        NSString* currentProtocalName=[ProtocalList objectAtIndex:j];
        Protocol * currentProtocal=objc_getProtocol(currentProtocalName.UTF8String);
        unsigned int ProtocalMethodCount;
        struct objc_method_description * protocalMethodList=protocol_copyMethodDescriptionList(currentProtocal,NO, YES,&ProtocalMethodCount);
        NSMutableDictionary* curMethodList=[NSMutableDictionary dictionary];
        for(int k=0;k<ProtocalMethodCount;k++){
            struct objc_method_description currentMethod=protocalMethodList[k];
            NSString* MethodName=[NSString stringWithString:NSStringFromSelector(currentMethod.name)];
            NSString* TypeSignature=[NSString stringWithUTF8String:currentMethod.types];
            [curMethodList setObject:TypeSignature forKey:MethodName];
            
        }
        [dumpedProtocals setObject:curMethodList forKey:currentProtocalName];
        
        
    }
    NSLog(@"Finished Dumping");
}
-(NSMutableDictionary*)methodsForClass:(NSString*)className{
    NSLog(@"Start Dumping Methods");
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
    free(methods2);
    NSLog(@"Methods %@",returnDictionary);
    
    return returnDictionary;
    
}
-(NSMutableDictionary*)propertiesForClass:(NSString*)className{
     NSLog(@"Start Dumping Properties");
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
    NSLog(@"Properties %@",returnDictionary);
    return returnDictionary;
}
-(NSMutableDictionary*)ivarForClass:(NSString*)className{
     NSLog(@"Start Dumping IVARs");
    NSMutableDictionary* returnDict=[NSMutableDictionary dictionary];
    unsigned int count;
    Ivar * IvarList=class_copyIvarList(objc_getClass(className.UTF8String), &count);
    for(int i=0;i<count;i++){
        Ivar currentIvar=IvarList[i];
        NSString* IvarName=[NSString stringWithFormat:@"%s",ivar_getName(currentIvar)];
        NSString* IvarOffset=[NSString stringWithFormat:@"%lu",(unsigned long)ivar_getOffset(currentIvar)];
        NSLog(@"Pffset:%@",IvarOffset);
        NSDictionary* ivarInfoDict=[NSDictionary dictionaryWithObjectsAndKeys:IvarName,@"Name", IvarOffset,@"Offset",[NSString stringWithUTF8String:ivar_getTypeEncoding(currentIvar)],@"TypeEncoding",nil];
        //NSLog(@"iVARinfo:%@",ivarInfoDict);
        [returnDict setObject:ivarInfoDict forKey:[NSString stringWithUTF8String:ivar_getName(currentIvar)]];
        
        
        
    }
    free(IvarList);
    
    return returnDict;
}
-(NSMutableDictionary*)protocalForClass:(NSString*)className{
     NSLog(@"Start Dumping Protocals");
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
-(void)OutPutToPath:(NSString*)Path{
    [dumpedClasses writeToFile:[Path stringByAppendingString:@"/Classes.plist"] atomically:YES];
    [dumpedProtocals writeToFile:[Path stringByAppendingString:@"/Protocals.plist"]  atomically:YES];
    
}
@end
