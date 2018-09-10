//
//  NSURL+SM.m
//  AWYDownloadHelper
//
//  Created by awyys on 2017/6/23.
//  Copyright © 2017年 awyys. All rights reserved.
//

#import "NSURL+SM.h"

@implementation NSURL (SM)
-(NSURL *)sreamUrl{
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"sreaming";
    return components.URL;
}
@end
