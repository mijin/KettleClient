//
//  KettleClient.h
//  KettleClient
//
//  Created by Mijin Cho on 20/10/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncUdpSocket.h"
#import <UIKit/UIKit.h>


typedef void (^KettleSuccessBlock)(id obj);
typedef void (^KettleFailureBlock)();

typedef enum MessageRecieved
{
    kSuccess,
    kImproperCommandFormat,
    kCommandNotSupported,
    kNone,
    kNotPermmited,
    kOutofMemory,
    kUnknownCommand
    
}MessageRecieved;

@interface KettleClient : NSObject <NSStreamDelegate>{
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}

@property (nonatomic, strong,readwrite) NSInputStream *inputStream;
@property (nonatomic, strong,readwrite) NSOutputStream *outputStream;

@property (nonatomic, assign ) BOOL     isConnected;

@property (nonatomic, assign ) BOOL     isReading;
@property (nonatomic, assign ) BOOL     isSending;

+ (KettleClient *)sharedInstance;

- (void)start:(const char*)command success:(KettleSuccessBlock)successCompletion
       failure:(KettleFailureBlock)failureCompletion;


- (void)command:(NSData*) data  success:(KettleSuccessBlock)successCompletion
        failure:(KettleFailureBlock)failureCompletion;
@end