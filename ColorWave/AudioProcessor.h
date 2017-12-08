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

- (void)initialize:(UIViewController*) vc;
- (void)start;
- (void)stop;


@end
#endif /* AudioProcessor_h */
