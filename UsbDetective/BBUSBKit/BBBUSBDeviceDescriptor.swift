//
//  BBBUSBDescriptor.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/11.
//  Copyright © 2016 OTAKE Takayoshi. All rights reserved.
//

//
//  Refer to "Universal Serial Bus Specification Revision 2.0 (April 27, 2000)" for more information.
//

import Cocoa

public struct BBBUSBDeviceDescriptor {
  public var bLength: UInt8 = 0
  public var bDescriptorType: UInt8 = 0
  public var bcdUSB: UInt16 = 0
  public var bDeviceClass: UInt8 = 0
  public var bDeviceSubClass: UInt8 = 0
  public var bDeviceProtocol: UInt8 = 0
  public var bMaxPacketSize0: UInt8 = 0
  public var idVendor: UInt16 = 0
  public var idProduct: UInt16 = 0
  public var bcdDevice: UInt16 = 0
  public var iManufacturer: UInt8 = 0
  public var iProduct: UInt8 = 0
  public var iSerialNumber: UInt8 = 0
  public var bNumConfigurations: UInt8 = 0
  
  public var manufacturerString: String? = nil
  public var productString: String? = nil
  public var serialNumberString: String? = nil
  
  init() {
  }
}

public struct BBBUSBConfigurationDescriptor {
  public var bLength: UInt8 = 0
  public var bDescriptorType: UInt8 = 0
  public var wTotalLength: UInt16 = 0
  public var bNumInterfaces: UInt8 = 0
  public var bConfigurationValue: UInt8 = 0
  public var iConfiguration: UInt8 = 0
  public var bmAttributes: UInt8 = 0
  public var bMaxPower: UInt8 = 0
  
  public var configurationString: String? = nil
  public var interfaces: [BBBUSBInterfaceDescriptor] = []
  
  // [descriptorType : bytes]
  public var descriptors: [UInt8 : [UInt8]] = [:]
  
  init() {
  }
}

public struct BBBUSBInterfaceDescriptor {
  public var bLength: UInt8 = 0
  public var bDescriptorType: UInt8 = 0
  public var bInterfaceNumber: UInt8 = 0
  public var bAlternateSetting: UInt8 = 0
  public var bNumEndpoints: UInt8 = 0
  public var bInterfaceClass: UInt8 = 0
  public var bInterfaceSubClass: UInt8 = 0
  public var bInterfaceProtocol: UInt8 = 0
  public var iInterface: UInt8 = 0
  
  public var interfaceString: String? = nil
  public var endpoints: [BBBUSBEndpointDescriptor] = []
  
  // [descriptorType : bytes]
  public var descriptors: [UInt8 : [UInt8]] = [:]
  
  init() {
  }
}

public struct BBBUSBEndpointDescriptor {
  public var bLength: UInt8 = 0
  public var bDescriptorType: UInt8 = 0
  public var bEndpointAddress: UInt8 = 0
  public var bmAttributes: UInt8 = 0
  public var wMaxPacketSize: UInt16 = 0
  public var bInterval: UInt8 = 0
  
  init() {
  }
}
