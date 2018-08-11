//
//  NSObject+AOP.m
//  URLSession回顾
//
//  Created by ma qianli on 2018/8/8.
//  Copyright © 2018年 maqianli. All rights reserved.
//

#import "NSObject+AOP.h"


@implementation NSObject (AOP)


/**
 动态为类添加方法

 @param cls 添加到那个类
 @param sel 方法名
 @param method 方法
 @return 添加是否成功
 */
+(BOOL)addMethodWithClass:(Class)cls sel:(SEL)sel method:(Method)method{
        return class_addMethod(cls, sel,  method_getImplementation(method),  method_getTypeEncoding(method));
}

/**
 交换方法名对应的实现
 @param cls 在那个类中交换
 @param newSelector 新方法名
 @param oldSelector 老方法名
 */
+(void)exChangeMethodImpWithClass:(Class)cls newSelctor:(SEL)newSelector oldSelctor:(SEL)oldSelector{
    
    Method newMethod = class_getInstanceMethod(cls, newSelector);
    Method oldMethod = class_getInstanceMethod(cls, oldSelector);
    
    method_exchangeImplementations(newMethod, oldMethod);
}




@end
