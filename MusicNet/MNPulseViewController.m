//
//  MNPulseViewController.m
//  MusicNet
//
//  Created by Debjit Saha on 4/1/14.
//  Copyright (c) 2014 ___RIT___. All rights reserved.
//

#import "bwbp.h"
#import "fft.h"
#import "MNPulseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GPUImage.h"
#import "MNApiCreds.h"
#import "AFNetworking.h"
static int const WINDOW_SECONDS = 7;
static float const SAMPLING_PERIOD=0.5;
static int const BPM_L=40;
static int const BPM_H=170;
static int const FILTER_TIME=1;
static int const FINE_TUNING=1;

@interface MNPulseViewController() <AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLConnectionDelegate>
{
    GPUImageVideoCamera *videoCamera;
    GPUImageAverageColor *averageColor;
    NSMutableData *responseData;
}

@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong,nonatomic) AVCaptureSession *session;
@property (strong,nonatomic) NSMutableArray *scores;
@property (strong,nonatomic) NSMutableArray *bpm;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@property (nonatomic) float vdoFrameRate;
@property (nonatomic) BOOL frameTimeRefresh;
@property (nonatomic) int numberOfFrames;
@property (strong,nonatomic) NSMutableArray *frameCountArray;
@property (nonatomic) int halfCount;
@property (nonatomic) BOOL pauseBroke;
@property (nonatomic,strong) NSTimer *ignoreTimer;
@property (nonatomic,strong) NSTimer *beginTimer;
@end

@implementation MNPulseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _scores = [[NSMutableArray alloc] init];
    [self addLabelAnimation];
    _frameTimeRefresh = NO;
    _numberOfFrames = 0;
    _frameCountArray = [[NSMutableArray alloc]init];
    _halfCount=0;
    _pauseBroke=NO;
    _bpm = [[NSMutableArray alloc] init];
    [self setupGPUCamera];
    _ignoreTimer=[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ignoreFrames) userInfo:nil repeats:NO];
    // [self setupAVCapture];
    
    
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [videoCamera stopCameraCapture];
    [_ignoreTimer invalidate];
    [_beginTimer invalidate];
    
}
-(void) ignoreFrames{
    _beginTimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(beginRun) userInfo:nil repeats:YES];
    
}
-(void) addLabelAnimation{
    [UIView animateWithDuration:1.5 delay:0.1 options:UIViewAnimationOptionRepeat animations:^{
        self.promptLabel.alpha=0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.promptLabel.alpha=1;
        }
    }];
}
-(void) restore{
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        [self.promptLabel setAlpha: 1.0f];
    } completion:NULL];
    
}
-(void) setupGPUCamera{
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetMedium cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    _vdoFrameRate = videoCamera.frameRate;
    NSError *error = nil;
    if (![videoCamera.inputCamera lockForConfiguration:&error])
    {
        NSLog(@"Error locking for configuration: %@", error);
    }
    if ([videoCamera.inputCamera hasTorch] && [videoCamera.inputCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
    }
    [videoCamera.inputCamera unlockForConfiguration];
    averageColor = [[GPUImageAverageColor alloc] init];
    [videoCamera addTarget:averageColor];
    __weak typeof(self) weakSelf = self;
    [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime){
        weakSelf.numberOfFrames++;
        float h=0,v=0,s=0;
        RGBtoHSV(redComponent, greenComponent, blueComponent, &h, &s, &v);
        
        if(weakSelf.frameTimeRefresh && (weakSelf.halfCount >= 2*WINDOW_SECONDS) ){
            int frames7SecondsBack = [[weakSelf.frameCountArray objectAtIndex:(weakSelf.halfCount-2*WINDOW_SECONDS)] intValue];
            int framesNow =[[weakSelf.frameCountArray objectAtIndex:weakSelf.halfCount-1] intValue];
            weakSelf.vdoFrameRate = (framesNow-frames7SecondsBack)/WINDOW_SECONDS;
            weakSelf.frameTimeRefresh=NO;
            [weakSelf computeBPM];
        }
        static float lastH=0;
        float highPassValue=h-lastH;
        lastH=h;
        float lastHighPassValue=0;
        float lowPassValue=(lastHighPassValue+highPassValue)/2;
        float classif = redComponent/(greenComponent+blueComponent);
        if(classif > 1.5 && !weakSelf.pauseBroke){
            if(weakSelf.halfCount < 2*WINDOW_SECONDS){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.promptLabel.text = @"Detecting..";
                });
            }
            weakSelf.pauseBroke=YES;
        }
        if (classif > 1.5 && weakSelf.pauseBroke) {
            if(weakSelf.halfCount >= 2*WINDOW_SECONDS){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.promptLabel.text = @"Your Heart Rate is:";
                    [weakSelf restore];
                });
            }
        }
        if(classif < 1.5 && weakSelf.pauseBroke){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.promptLabel.text = @"Place your finger on the camera";
                [weakSelf addLabelAnimation];
            });
            [weakSelf.scores removeAllObjects];
            [weakSelf.frameCountArray removeAllObjects];
            weakSelf.pauseBroke=NO;
            weakSelf.halfCount=0;
        }
        if (weakSelf.pauseBroke) {
            [weakSelf.scores addObject: [NSNumber numberWithFloat:lowPassValue]];
        }
        
    }];
    [videoCamera startCameraCapture];
}
-(void) beginRun{
    [self.frameCountArray addObject:[NSNumber numberWithInt:self.numberOfFrames]];
    if (self.pauseBroke) {
        self.halfCount++;
    }
    if(self.halfCount>=2*WINDOW_SECONDS){
        self.frameTimeRefresh = YES;
    }
}
-(void)computeBPM{
    int sizeOfWindow = floor(WINDOW_SECONDS*self.vdoFrameRate);
    int bpmSamplingSamples = floor(SAMPLING_PERIOD*self.vdoFrameRate);
    float fcl = BPM_L*1.0/60;
    float fch = BPM_H*1.0/60;
    int windowStart = (self.halfCount-2*WINDOW_SECONDS)*bpmSamplingSamples;
    
    double x[sizeOfWindow];
    double fftx[2*sizeOfWindow];
    double gain[sizeOfWindow];
    
    for(int i=windowStart,j=0;i<windowStart + sizeOfWindow;i++,j++){
        /*@try {
         x[j]=[[self.scores objectAtIndex:i] doubleValue];
         }
         @catch (NSException *exception) {
         
         }*/
        x[j]=[[self.scores objectAtIndex:i] doubleValue];
    }
    BWfilter(fcl/self.vdoFrameRate*2,fch/self.vdoFrameRate*2,x,sizeOfWindow);
    
    int sizeAfterCutOff = sizeOfWindow - self.vdoFrameRate*FILTER_TIME;
    double stabilizationCutOff[sizeAfterCutOff];
    for (int i=0; i < sizeAfterCutOff; i++) {
        int index = i+ FILTER_TIME*(int)self.vdoFrameRate;
        stabilizationCutOff[i] = x[index];
    }
    
    for (int i = 0; i < sizeAfterCutOff; i++) {
        double multiplier = 0.5 * (1 - cos(2*M_PI*i/(sizeAfterCutOff-1)));
        stabilizationCutOff[i] = multiplier * stabilizationCutOff[i];
    }
    
    for (int i=0; i<sizeAfterCutOff; i++) {
        fftx[2*i]=stabilizationCutOff[i];
        fftx[2*i+1]=0.0;
    }
    
    FFT(fftx,sizeAfterCutOff, 1);
    complexAbsolute(fftx,gain,sizeAfterCutOff);
    
    int indexLow = floor(fcl * sizeAfterCutOff/self.vdoFrameRate);
    int indexHigh = floor(fch * sizeAfterCutOff/self.vdoFrameRate);
    int indexRange[indexHigh-indexLow+1];
    for (int i=indexLow,j=0;i<=indexHigh ; i++,j++) {
        indexRange[j]=i;
    }
    
    double *peaks=0;
    int *locations=0;
    int noOfpeaks=0;
    
    findPeaks(gain,indexLow,indexHigh,&peaks,&locations,&noOfpeaks);
    
    double *maxData=maxCalc(peaks,noOfpeaks);
    
    int maxFreqIndex=indexRange[locations[(int)maxData[1]]];
    float bpm = (maxFreqIndex-1) * (self.vdoFrameRate/sizeAfterCutOff) * 60;
    //[self.bpm addObject:[NSNumber numberWithFloat:bpm]];
    
    float freq_resolution = 1.0/WINDOW_SECONDS;
    float lowf = bpm/60 - 0.5*freq_resolution;
    float freq_inc = FINE_TUNING*1.0/60;
    int test_freqs = floor(freq_resolution/freq_inc);
    double power[test_freqs];
    double freqs[test_freqs];
    
    for (int i=0; i<test_freqs; i++) {
        freqs[i] = i*freq_inc + lowf;
    }
    for (int i=0; i<test_freqs; i++) {
        float re=0;
        float im=0;
        for (int j=0; j< sizeAfterCutOff; j++) {
            float phi = 2*M_PI*freqs[i]*(j/self.vdoFrameRate);
            re = re + stabilizationCutOff[j] * cos(phi);
            im = im + stabilizationCutOff[j] * sin(phi);
            
        }
        power[i]=re*re + im*im;
    }
    double *powerMax = maxCalc(power, test_freqs);
    int bpmFreq = floor(60*freqs[(int)powerMax[1]]);
    if (bpmFreq < BPM_L || bpmFreq> BPM_H) {
        bpmFreq = (BPM_H+BPM_L)/2;
    }
    [self.bpm addObject:[NSNumber numberWithInt:bpmFreq]];
    //NSLog(@"%f",bpmFreq);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.heartRateLabel setText:[NSString stringWithFormat:@"%i",bpmFreq]];
    });
    double dbpmFreq;
    dbpmFreq = bpmFreq;
    [self sendPulseData:dbpmFreq];
    free(peaks);
    free(locations);
    free(maxData);
    free(powerMax);
}


double* maxCalc(double *peaks,int no){
    double *maxdata = (double *)calloc(2, sizeof(double));
    if(no > 0){
        maxdata[0]=peaks[0];
        maxdata[1]=0;
    }
    for (int i=1; i<no; i++) {
        if (peaks[i]>maxdata[0]) {
            maxdata[0]=peaks[i];
            maxdata[1]=i;
        }
    }
    return maxdata;
}

void complexAbsolute(double *fft,double *y,int n){
    for(int i =0; i<n;i++){
        y[i] = sqrt(fft[2*i]*fft[2*i] + fft[2*i+1]*fft[2*i+1]);
    }
}

void findPeaks(double *values,int l,int h,double **peaks,int **locations,int *noOfPeaks){
    NSMutableArray *peakArray = [[NSMutableArray alloc] init];
    NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
    for(int i=l+1;i<h-1;i++){
        if (values[i] > values[i-1] && values[i] > values[i+1]) {
            [peakArray addObject:[NSNumber numberWithDouble:values[i]]];
            [locationsArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    *noOfPeaks = (int)[peakArray count];
    double *tempPeaks = (double *)calloc(*noOfPeaks , sizeof(double));
    int *tempLocations = (int *)calloc(*noOfPeaks , sizeof(int));
    for (int i=0; i<[peakArray count]; i++) {
        tempPeaks[i]=[[peakArray objectAtIndex:i] doubleValue];
        tempLocations[i] = [[locationsArray objectAtIndex:i] intValue];
    }
    *peaks=tempPeaks;
    *locations = tempLocations;
    
}

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        // r = g = b = 0
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h=2+(b-r)/delta;
    else
        *h=4+(r-g)/delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}


-(void) sendPulseData:(double)pulse{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kMNapiUrl]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *parameters = @{@"token": [NSNumber numberWithInt:[self.mntoken intValue]], @"pulseData" : [NSNumber numberWithFloat:pulse]};
    AFHTTPRequestOperation *op = [manager POST:@"sendPulse" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        if ([responseObject[@"status"] boolValue]) {
            //NSLog(@"Success");
            
        } else {
            
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[alertView show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //NSLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:operation.responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alertView show];
        
    }];
    [op start];
}






-(void) setupAVCapture{
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!error) {
        if ([device lockForConfiguration:&error]) {
            if ([device hasTorch] && [device isTorchModeSupported:AVCaptureTorchModeOn]) {
                [device setTorchMode:AVCaptureTorchModeOn];
            }
            [device unlockForConfiguration];
        }
        if ( [_session canAddInput:input] )
            [_session addInput:input];
        AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
        
        
        [videoDataOutput setVideoSettings:@{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) }];
        [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
        dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
        
        if ( [_session canAddOutput:videoDataOutput] )
            [_session addOutput:videoDataOutput];
        
        
        [_session startRunning];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]] message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    // got an image
    //CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(cvimgRef,0);
    // access the data
    size_t width=CVPixelBufferGetWidth(cvimgRef);
    size_t height=CVPixelBufferGetHeight(cvimgRef);
    // get the raw image bytes
    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
    size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
    float r=0,g=0,b=0;
    for(int y=0; y<height; y++) {
        for(int x=0; x<width*4; x+=4) {
            b+=buf[x];
            g+=buf[x+1];
            r+=buf[x+2];
            //          a+=buf[x+3];
        }
        buf+=bprow;
    }
    r/=(float) (width*height);
    g/=255*(float) (width*height);
    b/=(float) (width*height);
    //NSLog(@"%f",r/b);
    float h,s,v;
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    // simple highpass and lowpass filter
    
    static float lastH=0;
    float highPassValue=h-lastH;
    lastH=h;
    float lastHighPassValue=0;
    float lowPassValue=(lastHighPassValue+highPassValue)/2;
    printf("%f , ",lowPassValue);
    lastHighPassValue=highPassValue;
    
    //[self.redScores addObject: [NSNumber numberWithFloat:[self processPixelBuffer:pixelBuffer]]];
}
-(void) sendData{
    NSString *myRequestString = [NSString stringWithFormat:@"heartBeat=%@",@"75"];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@""]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myRequestData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
