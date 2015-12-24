//
//  RuntimeUtils.m
//  classRTDumper
//
//  Created by Zhang Naville on 24/12/2015.
//
//

#import "RuntimeUtils.h"
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import "CocoaSecurity.h"
#import <mach/mach_traps.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import <dlfcn.h>
#import <TargetConditionals.h>
#import "ObjcDefines.pch"
#define ProtocalRange NSMakeRange(0,sizeof(struct objc_protocol_t*))
#define Arch64Base 0x100000000
#define Arch32Base 0

@implementation RuntimeUtils
+(NSData*)dataForSegmentName:(NSString*)Segname SectName:(NSString*)SectName{
    
    //extern char *getsectdatafromheader(const struct mach_header *mhp,const char *segname,const char *sectname,uint32_t *size);
#ifdef __LP64__
      const struct mach_header_64* mh=(struct mach_header_64*)_dyld_get_image_header(0);
    uint64_t size;
    char* RawSectData=getsectdatafromheader_64(mh,Segname.UTF8String,SectName.UTF8String,&size);
#else
    const struct mach_header* mh=_dyld_get_image_header(0);
    uint32_t size;
    char* RawSectData=getsectdatafromheader(mh,Segname.UTF8String,SectName.UTF8String,&size);
#endif
    NSData* resultData=[NSData dataWithBytes:RawSectData length:size];
    return resultData;
    
    
}
+(NSMutableArray*)getProtocalList{
    NSMutableArray* ReturnArray=[NSMutableArray array];
    NSMutableData* protoListData=[[self dataForSegmentName:@"__DATA" SectName:@"__objc_catlist"] mutableCopy];
    while (protoListData.length>0) {
        NSData* currentProtocalData=[protoListData subdataWithRange:ProtocalRange];
        unsigned long long currentProtoAddress=[self addressForData:currentProtocalData]+_dyld_get_image_vmaddr_slide(0);
        [protoListData replaceBytesInRange:ProtocalRange withBytes:""];
        NSData* ProtoData=[self dataFromAddress:currentProtoAddress length:sizeof(struct objc_protocol_t)];
//
        
        
        

        
        
    }

    
    return ReturnArray;
}
+(unsigned long long)addressForData:(NSData*)data{
    NSString* CSE=[[[CocoaSecurityEncoder alloc] init] hex:data useLower:YES];
    NSMutableString* AAAA=[NSMutableString string];
    for(int i=0;i<CSE.length;i=i+2){
        [AAAA appendString:[CSE substringWithRange:NSMakeRange(CSE.length-i-2, 2)]];
        
    }
    unsigned long long result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:@"0x01000D99C0"];
    [scanner scanHexLongLong:&result];

    return result;
}
+(unsigned long long)offsetForVMAddress:(unsigned long long)Address{
#ifdef __LP64__
    return Address-Arch64Base;
#else
    return Address-Arch32Base;
#endif
    }

+(NSData*)dataFromAddress:(unsigned long long)address length:(unsigned long long)length{
    NSData* returnData;
//#ifdef TARGET_OS_IPHONE
    pointer_t buf;
    uint32_t sz;
    
    task_t task;
    
    if(vm_protect(task, (vm_address_t)address,length, NO, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY)!=KERN_SUCCESS){
        NSLog(@"Mach VM RWC Permission Failed");
        exit(255);
        
        
    }
    if (vm_read(task,address,length, &buf, &sz) != KERN_SUCCESS) {
        NSLog(@"Mach VM Read Failed");
        exit(255);

    }
    returnData=[NSData dataWithBytes:buf length:sz];
//#elif TARGET_OS_MAC
    
//#endif
    return returnData;
}

@end
