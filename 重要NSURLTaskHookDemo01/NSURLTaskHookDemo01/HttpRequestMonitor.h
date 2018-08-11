//
//  HttpRequestMonitor.h
//  NSURLTaskHookDemo01
//
//  Created by ma qianli on 2018/8/10.
//  Copyright © 2018年 ma qianli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestMonitor : NSObject
//该数组用来记录网络请求信息，里面元素是HttpTransationModel对象
@property (nonatomic, strong) NSMutableArray *array;

//管理器单例
+(instancetype)shared;


@end
