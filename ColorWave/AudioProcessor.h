//
//  AudioProcessor.h
//  ColorWave
//
//  Created by Oscar on 12/6/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef AudioProcessor_h
#define AudioProcessor_h
@interface AudioProcessor : NSObject


//- (void)setUpdateBlock:(void(^)(void))updateBlock;
//- (void)setArrays:(float*)fftArr mfccArr:(float*) mfccArr;
- (void)initialize:(UIViewController*) vc;
- (void)start;
- (void)stop;


@end
#endif /* AudioProcessor_h */
