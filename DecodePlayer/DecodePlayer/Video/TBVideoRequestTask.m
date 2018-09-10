//
//  TBVideoRequestTask.m
//  avplayerSavebufferData
//
//  Created by qianjianeng on 15/9/18.
//  Copyright (c) 2015年 qianjianeng. All rights reserved.
//
//// github地址：https://github.com/suifengqjn/TBPlayer

#import "TBVideoRequestTask.h"
#import "DecodeHelp.h"
typedef void(^DecodeCompletionBlock)(NSData *currentData,NSData *decodeData);

@interface TBVideoRequestTask () <NSURLConnectionDataDelegate, AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSURL           *url;
@property (nonatomic        ) NSUInteger      offset;

@property (nonatomic        ) NSUInteger      videoLength;
@property (nonatomic, strong) NSString        *mimeType;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableArray  *taskArr;

@property (nonatomic, assign) NSUInteger      downLoadingOffset;
@property (nonatomic, assign) BOOL            once;

@property (nonatomic, strong) NSFileHandle    *fileHandle;
@property (nonatomic, strong) NSString        *tempPath;

@property(nonatomic, assign) int keyValue;

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSMutableArray<NSData *> *reciveDataArray;

@property (nonatomic, strong) DecodeHelp *decodeHelp;

@end

@implementation TBVideoRequestTask

- (NSLock *)lock
{
    if (_lock == nil) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}
- (NSMutableArray<NSData *> *)reciveDataArray
{
    if (_reciveDataArray == nil) {
        _reciveDataArray = [NSMutableArray array];
    }
    return _reciveDataArray;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _taskArr = [NSMutableArray array];
        
    }
    return self;
}

- (DecodeHelp *)decodeHelp
{
    if (_decodeHelp == nil) {
        _decodeHelp = [[DecodeHelp alloc] init];
    }
    return _decodeHelp;
}

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset
{
    self.url = url;
    _offset = offset;
    
//    _tempPath = NSTemporaryDirectory();
//    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    _tempPath =  [NSTemporaryDirectory() stringByAppendingPathComponent:self.url.lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_tempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
        
    } else {
        [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
    }
    
    //如果建立第二次请求，先移除原来文件，再创建新的
    if (self.taskArr.count >= 1) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
    }
    
    _downLoadingOffset = 0;
    
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    
    if (offset > 0 && self.videoLength > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)offset, (unsigned long)self.videoLength - 1] forHTTPHeaderField:@"Range"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dragSlider) name:@"DragSlider" object:nil];
    
    [self.connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
       
}



- (void)cancel
{
    [self.connection cancel];
    
}

- (void)dragSlider
{
    [self.reciveDataArray removeAllObjects];
}


#pragma mark -  NSURLConnection Delegate Methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   _isFinishLoad = NO;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
    
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    NSLog(@"====================%@",response);
    NSUInteger videoLength;
    
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    
    self.videoLength = videoLength;
    self.mimeType = httpResponse.allHeaderFields[@"Content-Type"];
    

    if ([self.delegate respondsToSelector:@selector(task:didReceiveVideoLength:mimeType:)]) {
        [self.delegate task:self didReceiveVideoLength:self.videoLength mimeType:self.mimeType];
    }
    
    [self.taskArr addObject:connection];
    
    
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_tempPath];
    
   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [self.fileHandle seekToEndOfFile];
    
    _downLoadingOffset += data.length;
    
    if(self.keyValue == 0)
    {
        _downLoadingOffset -= 3;
    }
    
    self.keyValue = 1;
    
    [self.reciveDataArray addObject:data];

    while (1) {
        
        if (self.reciveDataArray.count)
        {
            
            [self.lock lock];
            
            NSData *firstData = self.reciveDataArray[0];
            
            [self.reciveDataArray removeObject:firstData];

            [self.lock unlock];
            
            [self.decodeHelp decryptionData:firstData completion:^(NSData *currentData, NSData *decodeData) {
                
                [self.fileHandle writeData:decodeData];
                
                if ([self.delegate respondsToSelector:@selector(didReceiveVideoDataWithTask:)]) {
                    [self.delegate didReceiveVideoDataWithTask:self];
                }
            }];
            
        }else
        {
            break;
        }
        
    }
    
    
//    if ([self.delegate respondsToSelector:@selector(didReceiveVideoDataWithTask:)]) {
//        [self.delegate didReceiveVideoDataWithTask:self];
//    }
    
    
}




- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (self.taskArr.count < 2) {
        _isFinishLoad = YES;
        
        //这里自己写需要保存数据的路径
//        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//        NSString *movePath =  [document stringByAppendingPathComponent:@"保存数据.mp4"];
//
//        BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:_tempPath toPath:movePath error:nil];
//        if (isSuccess) {
//            NSLog(@"rename success");
//        }else{
//            NSLog(@"rename fail");
//        }
//        NSLog(@"----%@", movePath);
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingWithTask:)]) {
        [self.delegate didFinishLoadingWithTask:self];
    }
    
}

//网络中断：-1005
//无网络连接：-1009
//请求超时：-1001
//服务器内部错误：-1004
//找不到服务器：-1003
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code == -1001 && !_once) {      //网络超时，重连一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self continueLoading];
        });
    }
    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
        [self.delegate didFailLoadingWithTask:self WithError:error.code];
    }
    if (error.code == -1009) {
        NSLog(@"无网络连接");
    }
}


- (void)continueLoading
{
    _once = YES;
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    
    [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)_downLoadingOffset, (unsigned long)self.videoLength - 1] forHTTPHeaderField:@"Range"];
    
    
    [self.connection cancel];
     self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
}

- (void)clearData
{
    [self.connection cancel];
    //移除文件
    [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];

}
@end
