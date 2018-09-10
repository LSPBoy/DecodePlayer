//
//  avplayerVC.m
//  TBPlayer
//
//  Created by qianjianeng on 16/2/27.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "AvplayerController.h"
#import "TBPlayer.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface AvplayerController ()

@property (nonatomic, strong) TBPlayer *player;
@property (nonatomic, strong) UIView *showView;
@end

@implementation AvplayerController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.showView = [[UIView alloc] init];
    self.showView.backgroundColor = [UIColor redColor];
    self.showView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.showView];
    
    
    
//    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    NSString *movePath =  [document stringByAppendingPathComponent:@"保存数据.mp4"];
//
//    NSURL *localURL = [NSURL fileURLWithPath:movePath];
    
    NSURL *url = [NSURL URLWithString:@"http://ovut6rafg.bkt.clouddn.com/test_enc.mp4?attname=&e=1530181620&token=VALm3xwOsOs-xDz5Q0ct_Mkwt6ZAdPaKCw7_-yzG:3IUn08htehk6dWG7GaYHAyvlKqU"];
    
    url = [NSURL URLWithString:@"http://ovut6rafg.bkt.clouddn.com/test_enc.mp4"];
//    url = [NSURL URLWithString:@"http://ovut6rafg.bkt.clouddn.com/test_enc.mp3"];
//    url = [NSURL URLWithString:@"http://ovut6rafg.bkt.clouddn.com/test_enc.mpg"];
//    url = [NSURL URLWithString:@"http://ovut6rafg.bkt.clouddn.com/test_enc.avi"];
//    url = [NSURL URLWithString:@"http://ovut6rafg.bkt.clouddn.com/test_enc.wma"];
    [[TBPlayer sharedInstance] playWithUrl:url showView:self.showView];

}




@end
