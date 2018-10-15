//
//  VIMediaCacheAdapter.m
//  PNPlayer
//
//  Created by ada on 2018/10/9.
//  Copyright © 2018年 PN. All rights reserved.
//

#import "VIMediaCacheAdapter.h"
#import "VIResourceLoaderManager.h"
#import "VICacheManager.h"
#import "WJLoggingAPI.h"
#import "WJConfig.h"
#import <UIKit/UIKit.h>

#define WJ_PLAYER_MEDIA_EXPIRED_CACHE_KEY   @"WJPlayerMediaExpiredCache"

//默认缓存两天
#define WJ_PLAYER_MEDIA_CACHE_EXPIRED_DURATION  60*60*24*2


@interface VIMediaCacheAdapter ()

@property(nonatomic, strong) NSMutableDictionary *resourceLoaders;


@property(nonatomic, strong) NSMutableDictionary *expiredTimes;

//过期时长
@property(nonatomic, assign) NSTimeInterval expiredDuration;

@end

@implementation VIMediaCacheAdapter

-(void)handleApplicationDidEnterBackgroundNotification:(NSNotification*)notification {
    [[NSUserDefaults standardUserDefaults] setObject:_expiredTimes forKey:WJ_PLAYER_MEDIA_EXPIRED_CACHE_KEY];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _expiredDuration = WJ_PLAYER_MEDIA_CACHE_EXPIRED_DURATION;
        self.resourceLoaders = [[NSMutableDictionary alloc] init];
        self.expiredTimes = [[NSMutableDictionary alloc] init];
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:WJ_PLAYER_MEDIA_EXPIRED_CACHE_KEY];
        if ([data count] > 0) {
            [self.expiredTimes addEntriesFromDictionary:data];
        }
        
        //加载配置
        NSDictionary *config = [WJConfig dictionaryForKey:@"WJPlayerCacheVI"];
        if (config && [config[@"expiredDuration"] isKindOfClass:[NSNumber class]]) {
            self.expiredDuration = [config[@"expiredDuration"] integerValue];
        }
        
        if ([_expiredTimes count] > 0) {
            NSDictionary *dicts = [_expiredTimes copy];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __block BOOL needCache = NO;
                [dicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    NSString *keyStr = (NSString*)key;
                    NSNumber *valNum = (NSNumber*)obj;
                    if ([valNum doubleValue] > [[NSDate date] timeIntervalSince1970]) {
                        NSError *error = nil;
                        [VICacheManager cleanCacheForURL:[NSURL URLWithString:keyStr] error:&error];
                        if (!error) {
                            needCache = YES;
                            WJLogDebug(@"删除缓存媒体文件成功~ url:%@",keyStr);
                        } else {
                            WJLogError(@"删除缓存失败~ url:%@ error:%@", keyStr,error);
                        }
                    }
                }];
                if (needCache) [[NSUserDefaults standardUserDefaults] setObject:self.expiredTimes forKey:WJ_PLAYER_MEDIA_EXPIRED_CACHE_KEY];
            });
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

#pragma mark IWJMediaCache
-(AVPlayerItem*)getPlayerItem:(NSURL*)url {
    if (url) {
        VIResourceLoaderManager *resourceLoader = nil;
        NSString *key = url.absoluteString;
        [_expiredTimes setObject:@([[NSDate date] timeIntervalSince1970] + WJ_PLAYER_MEDIA_CACHE_EXPIRED_DURATION) forKey:key];
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

-(unsigned long long)cachedSize {
    NSError *error = nil;
    unsigned long long size = [VICacheManager calculateCachedSizeWithError:&error];
    if (error) {
        size = 0;
        if (error) WJLogError(@"%@",error);
    }
    return size;
}

-(void)cleanCacheWithURL:(NSURL *)url {
    if (url) {
        NSError *error = nil;
        [VICacheManager cleanCacheForURL:url error:&error];
        if (error) WJLogError(@"%@",error);
    }
}

-(void)cleanAllCache {
    NSError *error = nil;
    [VICacheManager cleanAllCacheWithError:&error];
    if (error) WJLogError(@"%@",error);
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
