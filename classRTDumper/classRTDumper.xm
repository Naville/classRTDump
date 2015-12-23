#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>
#import "Dumper.h"
NSMutableArray* classList=[NSMutableArray array];
NSMutableArray* protocalList=[NSMutableArray array];
%ctor{
    //Protocol **objc_copyProtocolList(unsigned int *outCount)
    
    unsigned int count;
    const char **classes;
    Dl_info info;
    intptr_t Address=_dyld_get_image_vmaddr_slide(0);
    dladdr(&Address, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    
    for (int i = 0; i < count; i++) {
        NSLog(@"Class name: %s", classes[i]);
        [classList addObject:[NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding]];

        
    }
    free(classes);
    unsigned int protocolNumber;
    Protocol **Protocols=objc_copyProtocolList(&protocolNumber);
    for(int j=0;j<protocolNumber;j++){
        Protocol* currentProtocal=Protocols[j];
        NSString* protocalName=[NSString stringWithUTF8String:protocol_getName(currentProtocal)];
        [protocalList addObject:protocalName];
        
        
    }
    free(Protocols);
    
    
    Dumper* dumper=[Dumper dumper];
    [dumper setupWithClassList:classList protocalList:protocalList];
    [dumper startDump];
    [dumper OutPutToPath:[NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]];
    
}