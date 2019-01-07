//
//  USBDeviceInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"

@interface USBDeviceInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBDeviceInterfaceLatest ** device;

- (instancetype)initWithService:(io_service_t)service;
- (instancetype)initWithDevice:(IOUSBDeviceInterfaceLatest **)device;

- (IOUSBConfigurationDescriptor *)getConfigurationDescriptor:(NSError **)error;
- (IOReturn)open;
- (IOReturn)close;
- (IOReturn)getUSBInterfaceIterator:(io_iterator_t *)iterator;

/// Control transfer on default pipe (endpoint0)
- (IOReturn)deviceRequestWithRequestType:(UInt8)bmRequestType request:(UInt8)bRequest value:(UInt16)wValue index:(UInt16)wIndex length:(UInt16)wLength data:(void *)pData __deprecated;

/// Control transfer on default pipe (endpoint0)
///
/// the `request.wLenData` will be updated of after requested
- (BOOL)deviceRequest:(IOUSBDevRequest *)request error:(NSError **)error;
- (NSString *)getStringDescriptorAtIndex:(UInt8)index error:(NSError **)error;

@end
