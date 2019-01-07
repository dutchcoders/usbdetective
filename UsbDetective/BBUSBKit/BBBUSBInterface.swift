//
//  BBBUSBInterface.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

import Foundation
// import BBBUSBKitPrivate

public class BBBUSBInterface {
  public let descriptor: BBBUSBInterfaceDescriptor
  
  let service: io_service_t
  let interface: USBInterfaceInterface
  weak var device: BBBUSBDevice!
  
  init?(service: io_service_t, device: BBBUSBDevice, descriptor: BBBUSBInterfaceDescriptor) {
    self.service = service
    
    guard let interface = USBInterfaceInterface(service: service) else {
      IOObjectRelease(service)
      return nil // `deinit` is not called
    }
    self.interface = interface
    self.device = device
    self.descriptor = descriptor
  }
  
  deinit {
    IOObjectRelease(service)
  }
  
  
  public func open() throws {
    let err = interface.open()
    if err != kIOReturnSuccess {
      throw BBBUSBDeviceError.IOReturnError(err: Int(err))
    }
  }
  
  public func close() throws {
    let err = interface.close()
    if (err == kIOReturnNotOpen) {
      // Ignore
    }
    else if (err != kIOReturnSuccess) {
      throw BBBUSBDeviceError.IOReturnError(err: Int(err))
    }
  }
  
  public func listEndpoints() -> [BBBUSBEndpoint] {
    var endpoints: [BBBUSBEndpoint] = []
    for epDesc in descriptor.endpoints {
      endpoints.append(BBBUSBEndpoint(interface: self, descriptor: epDesc))
    }
    return endpoints
  }
}
