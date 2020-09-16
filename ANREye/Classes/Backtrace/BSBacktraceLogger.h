//
//  BSBacktraceLogger.h
//  BSBacktraceLogger
//
//  Created by 张星宇 on 16/8/27.
//  Copyright © 2016年 bestswifter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

@interface StackModel : NSObject

@property (nonatomic, copy) NSString *dli_sname;
@property (nonatomic, copy) NSString *dli_fname;
@property (nonatomic, assign) id dli_saddr;
@property (nonatomic, assign) id dli_fbase;
@property (nonatomic, assign) uintptr_t offset;
@property (nonatomic, assign) uintptr_t address;


@end


@interface BSBacktraceLogger : NSObject

+ (NSArray *)backtraceOfMachthread:(thread_t)thread;

@end


