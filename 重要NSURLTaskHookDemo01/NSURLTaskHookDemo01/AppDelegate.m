//
//  AppDelegate.m
//  NSURLTaskHookDemo01
//
//  Created by ma qianli on 2018/8/10.
//  Copyright © 2018年 ma qianli. All rights reserved.
//

#import "AppDelegate.h"
#import <execinfo.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

void HandleException(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];
    NSLog(@"%@", exceptionInfo);
}

void SignalExceptionHandler(int signal){
    
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Stack:\n"];
    void* callstack[128];//堆栈方法数组
    int i, frames = backtrace(callstack, 128);//从iOS的方法backtrace中获取错误堆栈方法指针数组，返回数目
    char** strs = backtrace_symbols(callstack, frames);//符号化
    
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }

    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [documents stringByAppendingPathComponent:@"signal.txt"];
    
    [mstr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

//关于signal信号的捕捉，在Xcode调试时，Debugger模式会先于我们的代码catch到所有的crash，
//所以需要直接从模拟器中进入程序才可以测试
void InstallSignalHandler(void) {
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    InstallSignalHandler();
    NSSetUncaughtExceptionHandler(HandleException);
    
//    NSArray *array = @[@""];
//    array[1];
    
    int *i;
    free(i);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
