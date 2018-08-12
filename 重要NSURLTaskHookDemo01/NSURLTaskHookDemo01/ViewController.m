//
//  ViewController.m
//  NSURLTaskHookDemo01
//
//  Created by ma qianli on 2018/8/10.
//  Copyright © 2018年 ma qianli. All rights reserved.
//

#import "ViewController.h"
#import "HttpRequestMonitor.h"
#import "HttpTransationModel.h"

@interface ViewController ()<NSURLSessionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnClicked:(id)sender {

    [self baiduRequest];
    [self csdnRequest];
    [self baiduRequest];
    [self csdnRequest];
    
    [self baiduRequestWithDelegate];
}

-(void)baiduRequestWithDelegate{
    NSString *string = @"https://www.baidu.com";
    NSURL *url = [NSURL URLWithString:string];
    
    //1.获取会话对象
    NSURLSession *session0 = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //2.创建会话任务
    NSURLSessionDataTask *task = [session0 dataTaskWithURL:url];
    
    //3.启动任务
    [task resume];
}

#pragma mark -- NSURLSessionTaskDelegate
/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didCompleteWithError:(nullable NSError *)error{
//    NSLog(@"error = %@", error);
//}


#pragma mark -- NSURLSessionDataDelegate
/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//    didReceiveData:(NSData *)data{
//    //NSLog(@"didReceiveData = %@", [[NSString alloc]initWithData:data encoding:4]);
//}

#pragma mark -------

-(void)baiduRequest{
    NSString *string = @"https://www.baidu.com";
    NSURL *url = [NSURL URLWithString:string];
    
    //1.获取会话对象
    //NSURLSession *session0 = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    //NSURLSession *session0 = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSession *session0 = [NSURLSession sharedSession];
    
    //2.创建会话任务
    NSURLSessionDataTask *task = [session0 dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
                if (error) {
                    NSLog(@"%@", error);
                }else{
                    NSLog(@"%@", [[NSString alloc]initWithData:data encoding:4]);
                }
        
    }];
    
    //3.启动任务
    [task resume];
}

-(void)csdnRequest{
    NSString *string = @"https://www.csdn.net";
    NSURL *url = [NSURL URLWithString:string];
    
    //1.获取会话对象
    //NSURLSession *session0 = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    //NSURLSession *session0 = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSession *session0 = [NSURLSession sharedSession];
    
    //2.创建会话任务
    NSURLSessionDataTask *task = [session0 dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@", error);
                }else{
                    NSLog(@"%@", [[NSString alloc]initWithData:data encoding:4]);
                }
        
    }];
    
    //3.启动任务
    [task resume];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    HttpRequestMonitor *monitor = [HttpRequestMonitor shared];
    NSArray *array = monitor.array;
    [array enumerateObjectsUsingBlock:^(HttpTransationModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"end - begin: %f", [obj.endDate timeIntervalSince1970] - [obj.beginDate timeIntervalSince1970]);
        //NSLog(@"task: %@, %@", obj.task.originalRequest.URL, obj.task.response);
        
        NSLog(@"-------------------");
    }];
    
}


























@end
