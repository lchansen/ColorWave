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
#import "ColorWave-Swift.h"

#define BUFFER_SIZE 1024
#define TIME_INTERVAL 0.05

@interface AudioProcessor()
@property (nonatomic) float *fftBassCircle;
@property (nonatomic) int circleIndex;
@property (nonatomic) float bassMagAvg;
@property (nonatomic) float maxMidFreq;
@property (nonatomic) int maxMidIndex;
@property (nonatomic) float **mfccData;
@property (nonatomic) int mfccIndex;
@property (nonatomic) int midTimeChange;
@property (strong, nonatomic) dispatch_queue_t serialQueue;
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) ViewController *masterVC;

@end

@implementation AudioProcessor

-(float**)mfccData{
    if(!_mfccData){
        _mfccIndex = 0;
        _mfccData = malloc(sizeof(float*)*30);
        for(int i = 0; i < 30; i++){
            _mfccData[i] = malloc(sizeof(float)*13);
        }
    }
    return _mfccData;
}

-(void)insertMfcc:(float*) mfccArr{
    self.mfccData[self.mfccIndex] = mfccArr;
}

-(dispatch_queue_t)serialQueue{
    if(!_serialQueue){
        _serialQueue = dispatch_queue_create("com.mfcc.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}

-(float*)fftBassCircle {
    if(!_fftBassCircle){
        _fftBassCircle = malloc(sizeof(float)*2.0/TIME_INTERVAL);
        for(int i = 0; i < 2.0/TIME_INTERVAL; i++){
            _fftBassCircle[i] = 9999;
        }
        self.circleIndex = 0;
    }
    return _fftBassCircle;
}

-(int)circleIndex{
    if(!_circleIndex){
        _circleIndex = 0;
    }
    return _circleIndex;
}
-(ViewController*)masterVC{
    if(!_masterVC){
        _masterVC = [[ViewController alloc] init];
    }
    return _masterVC;
}

-(void)insertToBass:(float)bassMag {
    self.circleIndex++;
    if(self.circleIndex >= 2.0/TIME_INTERVAL){
        self.circleIndex = 0;
    }
    self.fftBassCircle[self.circleIndex] = bassMag;
    float total = 0;
    for(int i = 0; i < 2/TIME_INTERVAL; i++){
        total += self.fftBassCircle[i];
    }
    self.bassMagAvg = total/(2/TIME_INTERVAL);
}

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
/*
- (void)setUpdateBlock:(void(^)(void))updateBlock{
    _updateData = updateBlock;
}

- (void)setArrays:(float*)fftArr mfccArr:(float* )mfccArr{
    self.fftPointer = fftArr;
    
    self.mfccPointer = mfccArr;
}
*/
-(void)initialize: (UIViewController*) vc{
    self.midTimeChange = 0;
    self.masterVC = (ViewController*) vc;
    
    NSLog(@"STARTING Microphone");
    __block AudioProcessor * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
    [self.audioManager play];
}
- (void)start{
    NSLog(@"STARTING UP");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL
                                     target:self
                                   selector:@selector(takeFFT)
                                   userInfo:nil
                                    repeats:YES];
    
    /*[NSTimer scheduledTimerWithTimeInterval:0.33
                                     target:self
                                   selector:@selector(calcMFCC)
                                   userInfo:nil
                                    repeats:YES];*/
}
- (void)stop{
    NSLog(@"STOPPING");
    [self.timer invalidate];
}


-(void) takeFFT {
    self.midTimeChange++;
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    int bassIndex1 = ceil(60/(self.audioManager.samplingRate/(BUFFER_SIZE)));
    int bassIndex2 = floor(200/(self.audioManager.samplingRate/(BUFFER_SIZE)));
    
    float bassTotal = 0;
    for(int i = bassIndex1; i < bassIndex2; i++){
        if(fftMagnitude[i] > 0){
            bassTotal += fftMagnitude[i];
        }
    }
    //NSLog(@"Average: %f", self.bassMagAvg);
    [self insertToBass:bassTotal];
    if(bassTotal > self.bassMagAvg){
        bool isLargest = true;
        int rangeLen = 0.3/TIME_INTERVAL;
        for(int i = 1; i <= rangeLen; i++){
            if(self.circleIndex-i < 0){
                if(self.fftBassCircle[(int)(2.0/TIME_INTERVAL) - abs(self.circleIndex-i)]*1.5 > bassTotal){
                    isLargest = false;
                    break;
                }
            }
            else {
                if(self.fftBassCircle[self.circleIndex -i]*1.5 > bassTotal){
                    isLargest = false;
                    break;
                }
            }
        }
        if(isLargest){
            // LUKE ADD COLOR CHANGE HERE!!!!!!!
            //NSLog(@"Total: %f", bassTotal);
            //NSLog(@"Change Bass Lights!");
        }
    }
    
    int midIndex1 = ceil(500/(self.audioManager.samplingRate/(BUFFER_SIZE)));
    int midIndex2 = floor(2000/(self.audioManager.samplingRate/(BUFFER_SIZE)));
    
    float maxVal = 0;
    int maxIndex = 0;

    
    for(int i = midIndex1; i < midIndex2; i++) {
        if(fftMagnitude[i] > maxVal) {
            maxVal = fftMagnitude[i];
            maxIndex = i;
        }
    }
    if(abs(maxIndex-self.maxMidIndex) > 15){
        if(self.midTimeChange > (0.25/TIME_INTERVAL)){
            self.maxMidIndex = maxIndex;
            NSLog(@"Mid changed");
            self.midTimeChange = 0;
        }
    }
    
    /*dispatch_async(self.serialQueue, ^{
        [self calcMFCC];
    });*/
}

-(void) calcMFCC{
    
    float* arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    float* fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    float* mfccCoefficients = malloc(sizeof(float)*13);
    
    [self.buffer fetchFreshData:arrayData withNumSamples:BUFFER_SIZE];
    
    [self.fftHelper performForwardFFTWithData:arrayData
                   andCopydBMagnitudeToBuffer:fftMagnitude];
    
    for(int i = 0; i < 13; i++){
        mfccCoefficients[i] = GetCoefficient(fftMagnitude, self.audioManager.samplingRate, 48, sizeof(float)*BUFFER_SIZE/2, i);
        //printf("%d: %f\n", i, mfccCoefficients[i]);
    }
    [self insertMfcc:mfccCoefficients];
    if(self.mfccIndex == 30){
        NSLog(@"This is a full array of data for mfcc");
        self.mfccIndex = 0;
    }
    else {
        //NSLog(@"calc'd mfcc: %d", self.mfccIndex);
        self.mfccIndex++;
    }
    
    //printf("%f\n", mfccCoefficients[1]);

}





@end


