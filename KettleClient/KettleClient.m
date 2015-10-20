//
//  KettleClient.m
//  KettleClient
//
//  Created by Mijin Cho on 20/10/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//

#import "KettleClient.h"

#import  <SystemConfiguration/CaptiveNetwork.h>

@interface KettleClient ()
{
    int     networkOperationCount;
}

@property (nonatomic, copy) KettleSuccessBlock successCompletionBlock;
@property (nonatomic, copy) KettleFailureBlock failureCompletionBlock;
@property (nonatomic, strong)  NSTimer *timer;
@end

@implementation KettleClient
@synthesize inputStream, outputStream;

+ (KettleClient *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static KettleClient * sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KettleClient alloc] init];
    });
    return sharedInstance;
}


-(id)init
{
    if(self = [super init])
    {
    }
    return self;
}



- (void)start:(const char*)command success:(KettleSuccessBlock)successCompletion
       failure:(KettleFailureBlock)failureCompletion;
{
  
    
    if (self.successCompletionBlock)
        self.successCompletionBlock = nil;
    if (successCompletion)
        self.successCompletionBlock = successCompletion;
    
    if (self.failureCompletionBlock)
        self.failureCompletionBlock = nil;
    if (failureCompletion)
        self.failureCompletionBlock = failureCompletion;


    [self start];
}

- (void)start
{
    NSString* address = @"IP Address";
    int port;
    NSLog(@"ip Address %@",address);
  
    _isConnected = NO;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)address, port, &readStream, &writeStream);
   
    if (readStream != nil && writeStream != nil) {
    
        inputStream = (__bridge NSInputStream *) readStream;
        [inputStream open];
        [inputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        outputStream = (__bridge NSOutputStream *) writeStream;
        [outputStream setDelegate:self];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream open];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 60
                                              target:self
                                            selector:@selector(handleConnectionTimeout)
                                            userInfo:nil
                                             repeats:NO];
    
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent{
    
    NSString *io;
    if (theStream == inputStream)
        io = @"<<";
    else io = @">>";
    NSLog(@"%@",io);
    
    KettleClient *sharedSelf = [KettleClient sharedInstance];
   
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
          
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            if(theStream == outputStream )
            {
              
                if ([outputStream hasSpaceAvailable])
                {
                    if( !_isConnected)
                    {
                        _isConnected = YES;
                        if (sharedSelf.successCompletionBlock)
                            sharedSelf.successCompletionBlock(@"NSStreamEventHasSpaceAvailable");
                    }
                }
               
            }
        
          break;
            
        }
            
        case NSStreamEventHasBytesAvailable:
            

            if (theStream == inputStream) {
                _isSending = NO;

              
                uint8_t buffer[1024];
                int len = 0;
                
                
                while ([inputStream hasBytesAvailable]) {
                   
                    len = (int)[inputStream read:buffer maxLength:sizeof(buffer)];
                    
                   
                    if (len > 0)
                    {
                        
                    }
               }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            [self close];
            
            
            break;
            
        case NSStreamEventEndEncountered:
        {
            NSLog(@"NSStreamEventEndEncountered");
          
            break;
        }
        default:
            NSLog(@"Unknown event");
    }
    
}

- (void)command:(NSData*) data  success:(KettleSuccessBlock)successCompletion
         failure:(KettleFailureBlock)failureCompletion
{
    _isSending = YES;
    if (self.successCompletionBlock)
        self.successCompletionBlock = nil;
    if (successCompletion)
        self.successCompletionBlock = successCompletion;
    
    if (self.failureCompletionBlock)
        self.failureCompletionBlock = nil;
    if (failureCompletion)
        self.failureCompletionBlock = failureCompletion;
    
    
    NSInteger bytesWritten = [outputStream write:[data bytes] maxLength:[data length]];
   
    if (bytesWritten > 0)
    {
         NSLog(@"bytesWritten %d",(int)bytesWritten);
    }
}

-(void)close
{
    NSLog(@"socket close");
    
    if (outputStream != nil) {
        outputStream.delegate = nil;
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream close];
        outputStream = nil;
    }
    if (inputStream != nil) {
        [inputStream close];
        inputStream = nil;
    }
}


-(void)handleConnectionTimeout
{
    
    if(!_isConnected ||
       _isSending)
    {
        _isSending = NO;
        _isConnected = NO;
        
        KettleClient *sharedSelf = [KettleClient sharedInstance];
        if (sharedSelf.failureCompletionBlock)
            sharedSelf.failureCompletionBlock(@"Error");
        [self close];
        
    }
}

@end
