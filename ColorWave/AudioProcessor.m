//
//  AudioProcessor.m
//  ColorWave
//
//  Created by Oscar on 12/6/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioProcessor.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "math.h"
#import "libmfcc.h"

#define BUFFER_SIZE 4096

@interface AudioProcessor()
@property (nonatomic, copy, nonnull) void (^updateData)(void);
@property (nonatomic) float *fftPointer;
@property (nonatomic) float *mfccPointer;
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@end

@implementation AudioProcessor

-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}

-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    
    return _fftHelper;
}
- (void)setUpdateBlock:(void(^)(void))updateBlock{
    _updateData = updateBlock;
}

- (void)setArrays:(float*)fftArr mfccArr:(float* )mfccArr{
    self.fftPointer = fftArr;
    
    self.mfccPointer = mfccArr;
}

- (void)start{
    NSLog(@"STARTING UP");
    
    
    __block AudioProcessor * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
        
        
    }];
    
    [self.audioManager play];
    [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(calcMFCC)
                                   userInfo:nil
                                    repeats:YES];
}

-(float*) calcMFCC {
    
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    float* mfccCoefficients = malloc(sizeof(float)*13);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    for(int i = 0; i < 13; i++){
        mfccCoefficients[i] = GetCoefficient(fftMagnitude, 44100, 48, sizeof(float)*BUFFER_SIZE/2, i);
        printf("%d: %f\n", i, mfccCoefficients[i]);
    }
    
    return mfccCoefficients;
}





@end


