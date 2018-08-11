//
//  HttpTransationModel.h
//  NSURLTaskHookDemo01
//
//  Created by ma qianli on 2018/8/10.
//  Copyright © 2018年 ma qianli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpTransationModel : NSObject

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;

@end
