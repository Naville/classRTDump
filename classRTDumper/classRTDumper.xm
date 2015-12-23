#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>
#import "Dumper.h"
NSMutableArray* classList=[NSMutableArray array];
%ctor{
    
    
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
    Dumper* dumper=[Dumper dumper];
    [dumper setupWithList:classList];
    
}