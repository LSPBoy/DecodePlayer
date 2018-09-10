//
//  DecodeHelp.h
//  TBPlayer
//
//  Created by zhudou on 2018/7/12.
//  Copyright © 2018年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DecodeCompletionBlock)(NSData *currentData,NSData *decodeData);
@interface DecodeHelp : NSObject

- (void)decryptionData:(NSData *)currentData completion:(DecodeCompletionBlock)completionBlock;

@end
