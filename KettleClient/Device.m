//
//  Device.m
//  KettleClient
//
//  Created by Mijin Cho on 20/10/2015.
//  Copyright © 2015 Mijin Cho. All rights reserved.
//
#import "Device.h"

@implementation Device

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];    
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.version = [aDecoder decodeIntegerForKey:@"version"] ;
        self.addr = [aDecoder decodeObjectForKey:@"addr"];
         }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.type forKey:@"type"];
    [aCoder encodeInt:self.version forKey:@"version"];
    [aCoder encodeObject:self.addr forKey:@"addr"];
}
@end
