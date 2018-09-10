//
//  DecodeHelp.m
//  TBPlayer
//
//  Created by zhudou on 2018/7/12.
//  Copyright © 2018年 SF. All rights reserved.
//

#import "DecodeHelp.h"

@implementation DecodeHelp

- (void)decryptionData:(NSData *)currentData completion:(DecodeCompletionBlock)completionBlock
{
    
     static long long keyValue = 0;
    
    NSUInteger len = currentData.length;
    Byte *origin = malloc(len);
    memset(origin, 0, len);
    [currentData getBytes:origin length:len];
    
    if (keyValue == 0 ){
        Byte key[3];
        [currentData getBytes:key length:3];
        NSMutableString *tmp = [NSMutableString string];
        for (int i = 0; i < 3; i++){
            [tmp appendFormat:@"%c", key[i]];
        }
        keyValue = tmp.intValue;
        Byte *decode = malloc(len-3);
        memset(decode, 0, len-3);
        for(int i = 0; i < len; i ++){
            if (i > 2){
                decode[i - 3] = origin[i] ^ keyValue;
            }
        }
        NSData *deData = [NSData dataWithBytes:(const void*)decode length:len-3];
        //        NSLog(@"++++++++++%@",deData);
        free(origin);
        free(decode);
        !completionBlock ? : completionBlock(currentData,deData);
        
    }else{
        Byte *decode = malloc(len);;
        memset(decode, 0, len);
        for(int i = 0; i < len; i ++){
            decode[i] = origin[i] ^ keyValue;
        }
        NSData *deData = [NSData dataWithBytes:(const void*)decode length:len];
        //        decodeTotal += (long long)deData.length;
        //        NSLog(@"%lld", decodeTotal);
        free(origin);
        free(decode);
        !completionBlock ? : completionBlock(currentData,deData);
        
    }
}


@end
