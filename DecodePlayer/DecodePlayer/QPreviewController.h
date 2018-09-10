//
//  QPreviewController.h
//  TBPlayer
//
//  Created by zhudou on 2018/7/13.
//  Copyright © 2018年 SF. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@interface QPreviewController : QLPreviewController

@property (nonatomic, strong) NSURL *fileURL;

@end
