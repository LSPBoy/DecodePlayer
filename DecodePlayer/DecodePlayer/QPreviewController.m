//
//  QPreviewController.m
//  TBPlayer
//
//  Created by zhudou on 2018/7/13.
//  Copyright © 2018年 SF. All rights reserved.
//

#import "QPreviewController.h"

@interface QPreviewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@end

@implementation QPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
  
    return self.fileURL;
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    NSLog(@"视图即将dismiss");
}

@end
