//
//  BBBUSBKitCore.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

#import <Foundation/Foundation.h>

#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>

typedef IOUSBDeviceInterface650 IOUSBDeviceInterfaceLatest;
#define kIOUSBDeviceInterfaceIDLatest kIOUSBDeviceInterfaceID650

typedef IOUSBInterfaceInterface800 IOUSBInterfaceInterfaceLatest;
#define kIOUSBInterfaceInterfaceIDLatest kIOUSBInterfaceInterfaceID800


static const NSErrorDomain kBBBUSBKitIOReturnErrorDomain = @"com.bigbamboo.BBBUSBKit.IOReturn";
@interface NSError (BBBUSBKit_IOReturn)
+ (NSError *)BBBUSBKitErrorWithIOReturnError:(IOReturn)err;
@end
