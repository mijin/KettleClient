//
//  Device.h
//  KettleClient
//
//  Created by Mijin Cho on 20/10/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Device : NSObject <NSCoding>
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int version;
@property (nonatomic, strong) NSString *addr;
@end
