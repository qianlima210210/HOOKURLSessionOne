//
//  HttpRequestMonitor.m
//  NSURLTaskHookDemo01
//
//  Created by ma qianli on 2018/8/10.
//  Copyright © 2018年 ma qianli. All rights reserved.
/*
 先熟悉下概念，预热一下：
 
 id objc_msgSend(id self, SEL cmd, ...)
 这是个“参数个数可变的函数”，能接受两个或两个以上的参数，第一个参数代表接收者，第二个参数代表选择子（SEL是玄子的类型），后续参数就是消息中的那些参数，其顺序不变，选择子指的就是方法的名字。
 
 Method的定义如下
 typedef struct objc_method *Method;
 
 struct objc_method {
 SEL method_name;         // 方法名称
 char *method_typesE;    // 参数和返回类型的描述字串
 IMP method_imp;            // 方法的具体的实现的指针
 }
 
 IMP的定义如下
 typedef id (*IMP)(id, SEL, ...);
 
 编译后ipa，在运行时都是objc_msgSend函数的调用，即都成了全局函数的调用，换句话说都成了c语言层次的调用。
 */

#import "HttpRequestMonitor.h"
#import "NSObject+AOP.h"
#import "HttpTransationModel.h"

@interface HttpRequestMonitor ()

@end

@implementation HttpRequestMonitor

+ (void)load{
    [self prepareSwizzleResumeMethodForClass];
    [self prepareSwizzleDataTaskWithURLCompletionHandlerMethodForClass];
    [self prepareSwizzleSessionWithConfigurationDelegateDelegateQueueMethodForClass];
}
//准备对NSURLSession的类方法sessionWithConfiguration:delegate:delegateQueue:下钩子
+(void)prepareSwizzleSessionWithConfigurationDelegateDelegateQueueMethodForClass{
    if (NSClassFromString(@"NSURLSession")) {

        IMP originalAOPIMP = method_getImplementation(class_getClassMethod([self class], @selector(aop_sessionWithConfiguration:delegate:delegateQueue:)));

        Class currentClass = objc_getMetaClass("NSURLSession");

        while (class_getClassMethod(currentClass, @selector(sessionWithConfiguration:delegate:delegateQueue:))) {
            Class superClass = [currentClass superclass];

            IMP classIMP = method_getImplementation(class_getClassMethod(currentClass, @selector(sessionWithConfiguration:delegate:delegateQueue:)));
            IMP superclassIMP = method_getImplementation(class_getClassMethod(superClass, @selector(sessionWithConfiguration:delegate:delegateQueue:)));

            if (classIMP != superclassIMP &&
                originalAOPIMP != classIMP) {
                [self swizzleSessionWithConfigurationDelegateDelegateQueueMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
    }
}

//准备对NSURLSession的实例方法dataTaskWithURL:completionHandler:下钩子
+(void)prepareSwizzleDataTaskWithURLCompletionHandlerMethodForClass{
    if (NSClassFromString(@"NSURLSession")) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
        
        IMP originalAOPIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(aop_dataTaskWithURL:completionHandler:)));
        
        Class currentClass = [session class];
        
        while (class_getInstanceMethod(currentClass, @selector(dataTaskWithURL:completionHandler:))) {
            Class superClass = [currentClass superclass];
            
            IMP classIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(dataTaskWithURL:completionHandler:)));
            IMP superclassIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(dataTaskWithURL:completionHandler:)));
            
            if (classIMP != superclassIMP &&
                originalAOPIMP != classIMP) {
                [self swizzleDataTaskWithURLCompletionHandlerMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
        
        [session finishTasksAndInvalidate];
    }
}

//准备对NSURLSessionTask的实例方法resume下钩子
+(void)prepareSwizzleResumeMethodForClass{
    if (NSClassFromString(@"NSURLSessionTask")) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
        
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        
        IMP originalAOPIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(aop_resume)));
        
        Class currentClass = [localDataTask class];
        
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            
            IMP classIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            
            if (classIMP != superclassIMP &&
                originalAOPIMP != classIMP) {
                [self swizzleResumeMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}

//准备对实现NSURLSessionDelegate类的实例方法URLSession:task:didCompleteWithError:下钩子
+(void)prepareSwizzleURLSessionTaskDidCompleteWithErrorMethodForClass:(Class)cls{
    IMP originalAOPIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(aop_URLSession:task:didCompleteWithError:)));
    
    Class currentClass = cls;
    
    while (class_getInstanceMethod(currentClass, @selector(URLSession:task:didCompleteWithError:))) {
        Class superClass = [currentClass superclass];
        
        IMP classIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(URLSession:task:didCompleteWithError:)));
        IMP superclassIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(URLSession:task:didCompleteWithError:)));
        
        if (classIMP != superclassIMP &&
            originalAOPIMP != classIMP) {//originalAOPIMP等于classIMP，意味着已将交换过了,这里就防止多次交换
            [self swizzleURLSessionTaskDidCompleteWithErrorMethodForClass:currentClass];
        }
        currentClass = [currentClass superclass];
    }
}

+(void)swizzleResumeMethodForClass:(Class)cls{
    Method aop_ResumeMethod = class_getInstanceMethod(self, @selector(aop_resume));
    
    if ([self addMethodWithClass:cls sel:@selector(aop_resume) method:aop_ResumeMethod]) {
        [self exChangeMethodImpWithClass:cls newSelctor:@selector(aop_resume) oldSelctor:@selector(resume)];
    }
    
    /*
    //test证明交换后的实现imp1，是否等于原始实现imp0
    IMP imp0 = method_getImplementation(aop_ResumeMethod);
    
    Method method = class_getInstanceMethod(cls, @selector(resume));
    IMP im1 = method_getImplementation(method);
    if (imp0 == im1) {
        NSLog(@"===");
    }
    */
}

+(void)swizzleDataTaskWithURLCompletionHandlerMethodForClass:(Class)cls{
    Method aop_dataTaskWithURLCompletionHandlerMethod = class_getInstanceMethod(self, @selector(aop_dataTaskWithURL:completionHandler:));
    
    if ([self addMethodWithClass:cls sel:@selector(aop_dataTaskWithURL:completionHandler:) method:aop_dataTaskWithURLCompletionHandlerMethod]) {
        [self exChangeMethodImpWithClass:cls newSelctor:@selector(aop_dataTaskWithURL:completionHandler:) oldSelctor:@selector(dataTaskWithURL:completionHandler:)];
    }
}

+(void)swizzleSessionWithConfigurationDelegateDelegateQueueMethodForClass:(Class)cls{
    Method aop_sessionWithConfigurationDelegateDelegateQueueMethod = class_getClassMethod(self, @selector(aop_sessionWithConfiguration:delegate:delegateQueue:));
    
    if ([self addMethodWithClass:cls sel:@selector(aop_sessionWithConfiguration:delegate:delegateQueue:) method:aop_sessionWithConfigurationDelegateDelegateQueueMethod]) {
        [self exChangeMethodImpWithClass:cls newSelctor:@selector(aop_sessionWithConfiguration:delegate:delegateQueue:) oldSelctor:@selector(sessionWithConfiguration:delegate:delegateQueue:)];
    }
}

+(void)swizzleURLSessionTaskDidCompleteWithErrorMethodForClass:(Class)cls{
    
    Method aop_URLSessionTaskDidCompleteWithErrorMethod = class_getInstanceMethod(self, @selector(aop_URLSession:task:didCompleteWithError:));
    if ([self addMethodWithClass:cls sel:@selector(aop_URLSession:task:didCompleteWithError:) method:aop_URLSessionTaskDidCompleteWithErrorMethod]) {
        [self exChangeMethodImpWithClass:cls newSelctor:@selector(aop_URLSession:task:didCompleteWithError:) oldSelctor:@selector(URLSession:task:didCompleteWithError:)];
    }
}

#pragma mark -- aop_method钩子函数
-(void)aop_resume{
    [HttpRequestMonitor.shared addBeginDateWithTask:(NSURLSessionTask*)self];
    
    [self aop_resume];
}

-(NSURLSessionDataTask *)aop_dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    void (^aop_completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error){
        
        [[HttpRequestMonitor shared] addEndDateByResponse:(NSHTTPURLResponse*)response error:error];
        completionHandler(data, response, error);
    };
    
    return [self aop_dataTaskWithURL:url completionHandler:aop_completionHandler];
}

+(NSURLSession *)aop_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue{
    //只判断代理是否实现了URLSession:task:didCompleteWithError:，估计还是不够的；能否在没实现的情况下自己添加该方法的实现呢？，这样结束时间就不会丢了。
    if ([delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [HttpRequestMonitor prepareSwizzleURLSessionTaskDidCompleteWithErrorMethodForClass:delegate.class];
    }
    
    return [self aop_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

-(void)aop_URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    
    [HttpRequestMonitor.shared addEndDateByResponse:(NSHTTPURLResponse*)task.response error:error];
    [self aop_URLSession:session task:task didCompleteWithError:error];
}

#pragma mark -- 自己的
+(instancetype)shared{
    
    static HttpRequestMonitor *monitor;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        monitor = [HttpRequestMonitor new];
    });
    
    return monitor;
}

- (NSMutableArray *)array{
    if (_array == nil) {
        _array = [NSMutableArray array];
    }
    return _array;
}

//添加网络请求开始时间
-(void)addBeginDateWithTask:(NSURLSessionTask*)task{
    HttpTransationModel *model = [HttpTransationModel new];
    model.task = task;
    model.beginDate = [NSDate date];
    [[HttpRequestMonitor shared].array addObject:model];
}

//添加网络请求结束时间
-(void)addEndDateByResponse:(NSHTTPURLResponse*)response error:(NSError*)error{
    //请求失败用error
    if (response == nil && error != nil) {
        [self.array enumerateObjectsUsingBlock:^(HttpTransationModel *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.endDate == nil && obj.task.error == error) {
                obj.endDate = [NSDate date];
                *stop = YES;
            }
        }];
    }
    
    //请求成功用response
    if (response != nil && error == nil) {
        [self.array enumerateObjectsUsingBlock:^(HttpTransationModel *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.endDate == nil && obj.task.response == response) {
                obj.endDate = [NSDate date];
                *stop = YES;
            }
        }];
    }
    
    

}

@end
