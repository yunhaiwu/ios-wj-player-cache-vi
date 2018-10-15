//
//  VIMediaCacheAdapter.h
//  PNPlayer
//
//  Created by ada on 2018/10/9.
//  Copyright © 2018年 PN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWJMediaCache.h"



/**
 WJConfig
 
    WJPlayerCacheVI:{
        expiredDuration:(NSNumber)过期时长（秒）   default：两天
    }
 
 */
@interface VIMediaCacheAdapter : NSObject<IWJMediaCache>

@end
