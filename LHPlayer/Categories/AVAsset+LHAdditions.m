//
//  AVAsset+LHAdditions.m
//  LHPlayer
//
//  Created by 刘刘欢 on 16/12/6.
//  Copyright © 2016年 刘刘欢. All rights reserved.
//

#import "AVAsset+LHAdditions.h"

@implementation AVAsset (LHAdditions)

- (NSString *)title
{
    AVKeyValueStatus *status = [self statusOfValueForKey:@"commonMetadata" error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray *items = [AVMetadataItem metadataItemsFromArray:self.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
        if (items.count > 0) {
            AVMetadataItem *titleItem = [items firstObject];
            return (NSString *)titleItem.value;
        }
    }
    return nil;
}

@end
