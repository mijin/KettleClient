//
//  ViewController.m
//  KettleClient
//
//  Created by Mijin Cho on 20/10/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "Device.h"
#import "KettleClient.h"
#import "CircularSlider.h"

@interface ViewController ()
{
     GCDAsyncUdpSocket * udpSocket;
     Device * kettle;
}
@property (nonatomic, strong)  CircularSlider *slider;
@end

@implementation ViewController


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _slider = [[CircularSlider alloc]initWithFrame:
               CGRectMake((self.view.frame.size.width
                           - slider_width)/2,
                          150,
                          slider_width,
                          slider_width)];
    
     [self.view addSubview:_slider];
    [_slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newValue:(CircularSlider*)slider{
    
    int   waterTemp = slider.currentValue;
    
    //Send command to change temp.
    NSLog(@"Water Temp %d°", waterTemp );
}

-(void)udpSocket:(GCDAsyncUdpSocket *)socket disconnectedWithError:(NSError *)error {
    NSLog(@"Disconnected With Error - %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)socket onError:(NSError *)error {
    NSLog(@"Error - %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"didNotConnect");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"Didnt Send");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tags {
    NSLog(@"Did Send");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sender didReadData:(NSData *)data withTag:(long)tagz
{
    NSLog(@"%@", data);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    //unsigned char* array = (unsigned char*) [data bytes];
  
    NSString *receiveString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (receiveString)
    {
        
      
        Device *device = [[Device alloc] init];
        device.type = [receiveString characterAtIndex:1];
        device.version = [receiveString characterAtIndex:2];
        
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        device.addr = host;
        kettle = device;
        NSLog(@"Message from: %@:%hu", host, port);
        
    }
}

- (void)sendBroadcast
{

    // The socket will invoke our delegate methods using the usual delegate paradigm.
    // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
 
  
    udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error=nil;
    
    if (![udpSocket enableBroadcast:YES error:&error]) {
        NSLog(@"Error broadcast: %@", error);
        return;
    }
    
    if (![udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSUInteger size =  2;
    const char bytes[] = {0x67,0x7e};
    
    NSData* data = [[NSData alloc] initWithBytes:bytes length:sizeof(unsigned char)*size];
    
    NSString* ip = @"255.255.255.255";
    int port;
    
    [udpSocket sendData:data toHost:ip port:port withTimeout:-1 tag:0];
    
    NSLog(@"sendBroadcast toHost %@",ip);
}

- (void)sendCommand
{
    
    [[KettleClient sharedInstance] start:nil
                                 success:^(NSString* output)
     {
         
         const char bytes[] = {0x52,0x7e};
         NSData* data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
         

         
         [[KettleClient sharedInstance] command:data
                                        success:^(NSString* output)
          {
              
              
          } failure:^{
               NSLog(@"failure");
          }];
         
         
     } failure:^(NSError* error){
         NSLog(@"failure");
    
     }];
}
@end
