//
//  CustonImageView.m
//  ImageLoaderIndicator-OC
//
//  Created by Alpha Yu on 8/13/15.
//  Copyright (c) 2015 tlm group. All rights reserved.
//

#import "CustonImageView.h"
#import "UIImageView+WebCache.h"
#import "CircularLoaderView.h"

@implementation CustonImageView {
    CircularLoaderView *_progressIndicatorView;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        _progressIndicatorView = [[CircularLoaderView alloc] initWithFrame:CGRectZero];
        [self addSubview:_progressIndicatorView];
        _progressIndicatorView.frame = self.bounds;
        _progressIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        NSURL *url = [NSURL URLWithString:@"http://www.raywenderlich.com/wp-content/uploads/2015/02/mac-glasses.jpeg"];
        
        __weak CircularLoaderView* weakProgressIndicatorView = _progressIndicatorView;
        [self sd_setImageWithURL:url placeholderImage:nil options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            weakProgressIndicatorView.progress = (CGFloat)receivedSize / (CGFloat)expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakProgressIndicatorView reveal];
        }];
    }
    return self;
}

@end
