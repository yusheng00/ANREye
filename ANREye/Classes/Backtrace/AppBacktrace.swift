//
//  AppBacktrace.swift
//  Pods
//
//  Created by zixun on 16/12/19.
//
//

import Foundation

class AppBacktrace: NSObject {
    class func with(thread: thread_t) -> String {
        let data: [StackModel] = BSBacktraceLogger.backtrace(ofMachthread: thread) as? [StackModel] ?? [StackModel()]
        var resultString: String = ""
        for model in data {
            if model.dli_fname.hasPrefix("-") {
                
            } else {
                let name = try? parseMangledSwiftSymbol(model.dli_sname)
                if let tem = name {
                    if tem.children.count > 0 {
                        model.dli_sname = tem.description
                    }
                }
            }
            resultString = resultString.appendingFormat("%@ + %lu", model.dli_sname, model.offset)
            resultString.append(contentsOf: "\n")
            debugPrint(resultString)
        }
        return resultString
    }
    
    class func currentThread() -> String {
        let machThread = self.bs_machThread(from: Thread.current)
        return self.with(thread: machThread)
    }
    
    class func mainThread() -> String {
        let machThread = self.bs_machThread(from: Thread.main)
        return self.with(thread: machThread)
    }
    
    class func allThread() -> String {
        
        var threads: thread_act_array_t? = nil
        var thread_count = mach_msg_type_number_t()
        
        if task_threads(mach_task_self_, &(threads), &thread_count) != KERN_SUCCESS {
            return ""
        }
        
        var resultString = "Call Backtrace of \(thread_count) threads:\n"
        
        for i in 0..<thread_count {
            let index = Int(i)
            let string = self.with(thread: threads![index])
            debugPrint(string)
            resultString.append(string)
        }
        
        return resultString
    }
    
    
    
    static var main_thread_id: mach_port_t!
    
    
    private class func bs_machThread(from nsthread:Thread) -> thread_t {
        
        var name:[Int8] = Array(repeating:0, count:256)
        
        var list: thread_act_array_t? = nil
        var count = mach_msg_type_number_t()
        
        if task_threads(mach_task_self_, &(list), &count) != KERN_SUCCESS {
            return mach_thread_self()
        }
        
        let currentTimestamp = NSDate().timeIntervalSince1970
        let originName = nsthread.name
        nsthread.name = "\(currentTimestamp)"
        
        if nsthread.isMainThread {
            return self.main_thread_id
        }
        
        for i in 0..<count {
            
            let index = Int(i)
            let pt = pthread_from_mach_thread_np(list![index])
            if nsthread.isMainThread {
                
                if list![index] == self.main_thread_id  {
                    return list![index]
                }
            }
            
            if (pt != nil) {
                pthread_getname_np(pt!, &name, name.count)
                
                if String(utf8String: name) == nsthread.name {
                    nsthread.name = originName
                    return list![index]
                }
            }
            
            
        }
        nsthread.name = originName
        return mach_thread_self()
    }
}

