//
//  USBInterfaceInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/08.
//
//

#import "USBInterfaceInterface.h"

@interface USBInterfaceInterface ()

@property (assign, nonatomic, readwrite) IOUSBInterfaceInterfaceLatest ** interface;

@end

@implementation USBInterfaceInterface

- (instancetype)initWithService:(io_service_t)service {
  self = [super init];
  if (self) {
    IOCFPlugInInterface ** plugInInterface;
    SInt32 score;
    
    // Use IOReturn instead kern_return_t
    IOReturn err;
    err = IOCreatePlugInInterfaceForService(service, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
    if (err != kIOReturnSuccess) {
      return nil; // `dealloc` will be called
    }
    err = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceIDLatest), (LPVOID)&_interface);
    if (err != kIOReturnSuccess) {
      // Ignore result
      IODestroyPlugInInterface(plugInInterface);
      return nil; // `dealloc` will be called
    }
    
    // Ignore result
    IODestroyPlugInInterface(plugInInterface);
  }
  return self;
}

- (void)dealloc {
  IOReturn err = (*_interface)->Release(_interface);
  if (err != kIOReturnSuccess) {
    NSLog(@"Warning: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
  }
}

- (IOReturn)open {
  IOReturn err = (*_interface)->USBInterfaceOpen(_interface);
  if (err != kIOReturnSuccess) {
    NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
  }
  return err;
}

- (IOReturn)close {
  IOReturn err = (*_interface)->USBInterfaceClose(_interface);
  if (err == kIOReturnNotOpen) {
    // Ignore
  }
  else if (err != kIOReturnSuccess) {
    NSLog(@"Error: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
  }
  return err;
}

@end
