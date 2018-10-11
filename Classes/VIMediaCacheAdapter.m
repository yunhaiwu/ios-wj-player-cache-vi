//
//  VIMediaCacheAdapter.m
//  PNPlayer
//
//  Created by ada on 2018/10/9.
//  Copyright © 2018年 PN. All rights reserved.
//

#import "VIMediaCacheAdapter.h"
#import "VIResourceLoaderManager.h"

@interface VIMediaCacheAdapter ()

@property(nonatomic, strong) NSMutableDictionary *resourceLoaders;

@end

@implementation VIMediaCacheAdapter

-(instancetype)init {
    self = [super init];
    if (self) {
        self.resourceLoaders = [[NSMutableDictionary alloc] init];
        //删除过期视频
    }
    return self;
}

#pragma mark IWJMediaCache
-(AVPlayerItem*)getPlayerItem:(NSURL*)url {
    if (url) {
        VIResourceLoaderManager *resourceLoader = nil;
        NSString *key = url.absoluteString;
        if ([[_resourceLoaders allKeys] containsObject:key]) {
            resourceLoader = [_resourceLoaders objectForKey:key];
        } else {
            resourceLoader = [[VIResourceLoaderManager alloc] init];
            [_resourceLoaders setObject:resourceLoader forKey:key];
        }
        return [resourceLoader playerItemWithURL:url];
    }
    return nil;
}

-(void)cancelLoading:(NSURL*)url {
    if (url) {
        NSString *key = url.absoluteString;
        VIResourceLoaderManager *resourceLoader = _resourceLoaders[key];
        if (resourceLoader) {
            [resourceLoader cancelLoaders];
            [_resourceLoaders removeObjectForKey:key];
        }
    }
}

@end
