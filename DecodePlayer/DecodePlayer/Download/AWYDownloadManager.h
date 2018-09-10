//
//  AWYDownloadManager.h
//  AWYDownloadHelper
//
//  Created by awyys on 2017/6/22.
//  Copyright © 2017年 awyys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWYDownloadHelper.h"
@interface AWYDownloadManager : NSObject
//1.单例 2.字典保存 3.实现开始，暂停，开始，取消（单个任务，多个任务，all任务）


+ (instancetype)sharedInstance;



- (void)downLoader:(NSURL *)url downLoadInfo:(downLoadInfo)downLoadInfo progress:(downLoadProgressChange)progressBlock success:(downLoadSuccess)successBlock failed:(downLoadFailed)failedBlock;


- (void)pauseWithURL:(NSURL *)url;
- (void)resumeWithURL:(NSURL *)url;
- (void)cancelWithURL:(NSURL *)url;


- (void)pauseAll;
- (void)resumeAll;
@end
