//
//  AWYDownloadManager.m
//  AWYDownloadHelper
//
//  Created by awyys on 2017/6/22.
//  Copyright © 2017年 awyys. All rights reserved.
//

#import "AWYDownloadManager.h"
#import "NSString+MD5.h"
@interface AWYDownloadManager()<NSCopying, NSMutableCopying>
@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;
@end
@implementation AWYDownloadManager

static AWYDownloadManager *_sharedInstance;
+ (instancetype)sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [super allocWithZone:zone];
        });
    }
    return _sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedInstance;
}

// key: md5(url)  value: XMGDownLoader
- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

-(void)downLoader:(NSURL *)url downLoadInfo:(downLoadInfo)downLoadInfo progress:(downLoadProgressChange)progressBlock success:(downLoadSuccess)successBlock failed:(downLoadFailed)failedBlock{
    
    // 1. url
    NSString *urlMD5 = [url.absoluteString MD5String];
    
    // 2. 根据 urlMD5 , 查找相应的下载器
    AWYDownloadHelper *downLoader = self.downLoadInfo[urlMD5];
    if (downLoader == nil) {
        downLoader = [[AWYDownloadHelper alloc] init];
        self.downLoadInfo[urlMD5] = downLoader;
    }
    
    
    __weak typeof(self) weakSelf = self;
    [downLoader downloadWithURL:url downInfo:downLoadInfo downloadState:nil progress:progressBlock success:^(NSString *filePath){
        [weakSelf.downLoadInfo removeObjectForKey:urlMD5];
        // 拦截block
        successBlock(filePath);
    } error:failedBlock];

    // 下载完成之后, 移除下载器
    //

}



- (void)pauseWithURL:(NSURL *)url {
    
    NSString *urlMD5 = [url.absoluteString MD5String];
    AWYDownloadHelper *downLoader = self.downLoadInfo[urlMD5];
    [downLoader pause];
}
- (void)resumeWithURL:(NSURL *)url {
    NSString *urlMD5 = [url.absoluteString MD5String];
    AWYDownloadHelper *downLoader = self.downLoadInfo[urlMD5];
    [downLoader resumeTask];
}
- (void)cancelWithURL:(NSURL *)url {
    NSString *urlMD5 = [url.absoluteString MD5String];
    AWYDownloadHelper *downLoader = self.downLoadInfo[urlMD5];
    [downLoader cancel];
    
}


- (void)pauseAll {
    
    [self.downLoadInfo.allValues performSelector:@selector(pause) withObject:nil];
    
}
- (void)resumeAll {
    [self.downLoadInfo.allValues performSelector:@selector(resumeTask) withObject:nil];
}

@end
