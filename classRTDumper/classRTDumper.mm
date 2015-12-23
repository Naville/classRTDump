#line 1 "/Volumes/Swap/Development/classRTDumper/classRTDumper/classRTDumper.xm"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>
#import "Dumper.h"
static __attribute__((constructor)) void _logosLocalCtor_6abe01d2(){
    
    NSMutableArray* classList=[NSMutableArray array];
    NSMutableArray* protocalList=[NSMutableArray array];
    NSLog(@"classRTDump Loaded");
    unsigned int count;
    const char **classes;
    classes = objc_copyClassNamesForImage([[[NSBundle mainBundle] executablePath] UTF8String], &count);
    
    for (int i = 0; i < count; i++) {
        NSString* className=[NSString stringWithFormat:@"%s",classes[i]];
        
        [classList addObject:className];

        
    }
    free(classes);
    unsigned int protocolNumber;
    Protocol **Protocols=objc_copyProtocolList(&protocolNumber);
    for(int j=0;j<protocolNumber;j++){
        Protocol* currentProtocal=Protocols[j];
        NSString* protocalName=[NSString stringWithFormat:@"%s",protocol_getName(currentProtocal)];
       
        [protocalList addObject:protocalName];
        
        
    }
    free(Protocols);
    
    
    Dumper* dumper=[Dumper dumper];
    
    
    [dumper setupWithClassList:classList protocalList:protocalList];
    [dumper startDump];
    [dumper OutPutToPath:[NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]];
    
}
