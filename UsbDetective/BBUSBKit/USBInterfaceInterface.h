//
//  USBInterfaceInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/08.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"
#import "USBDeviceInterface.h"

@interface USBInterfaceInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBInterfaceInterfaceLatest ** interface;

- (instancetype)initWithService:(io_service_t)service;
- (IOReturn)open;
- (IOReturn)close;

@end
