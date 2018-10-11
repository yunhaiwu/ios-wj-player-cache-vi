//
//  WJMediaCacheBuilder.m
//  PNPlayer
//
//  Created by ada on 2018/10/9.
//  Copyright © 2018年 PN. All rights reserved.
//

#import "WJMediaCacheBuilder.h"
#import "VIMediaCacheAdapter.h"

@implementation WJMediaCacheBuilder

static VIMediaCacheAdapter *sharedInstance;

+(id<IWJMediaCache>)build {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VIMediaCacheAdapter alloc] init];
    });
    return sharedInstance;
}

@end
