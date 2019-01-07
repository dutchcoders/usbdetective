//
//  BBBUSBDevice.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

import Foundation
// import BBBUSBKitPrivate

public enum BBBUSBDeviceError: Error {
  case IOReturnError(err: Int)
  case illegalDescriptor
}

enum USBDescriptorType : UInt8 {
  case device = 1
  case configuration = 2
  case string = 3
  case interface = 4
  case endpoint = 5
  case deviceQualifier = 6
  case otherSpeedConfiguration = 7
  case interfacePower = 8
}

enum DeviceRequestRequestTypeDirection: UInt8 {
  case toDevice = 0
  case toHost = 1
}

enum DeviceRequestRequestTypeType: UInt8 {
  case standard = 0
  case `class` = 1
  case vendor = 2
}

enum DeviceRequestRequestTypeRecipient: UInt8 {
  case device = 0
  case interface = 1
  case endpoint = 2
  case other = 3
}

enum DeviceRequestRequestType {
  case requestType(DeviceRequestRequestTypeDirection, DeviceRequestRequestTypeType, DeviceRequestRequestTypeRecipient)
  var rawValue: UInt8 {
    get {
      switch self {
      case let .requestType(d7, d6_5, d4_0):
        return d7.rawValue << 7 | d6_5.rawValue << 5 | d4_0.rawValue
      }
    }
  }
}

enum DeviceRequestParticularRequest: UInt8 {
  case getDescriptor = 6
}


public class BBBUSBDevice: CustomStringConvertible {
  let service: io_service_t
  let device: USBDeviceInterface
  public let name: String
  public let path: String
  
  public var descriptor: BBBUSBDeviceDescriptor
  public var configurationDescriptor: BBBUSBConfigurationDescriptor
  
  init?(service: io_service_t) {
    self.service = service
    name = { () -> String in
      let nameBytes = UnsafeMutablePointer<Int8>.allocate(capacity: MemoryLayout<io_name_t>.size)
      _ = IORegistryEntryGetName(service, nameBytes)
      defer {
        nameBytes.deallocate(capacity: MemoryLayout<io_name_t>.size)
      }
      return String(cString: nameBytes)
    }()
    path = { () -> String in
      let pathBytes = UnsafeMutablePointer<Int8>.allocate(capacity: MemoryLayout<io_name_t>.size)
      _ = IORegistryEntryGetPath(service, kIOUSBPlane, pathBytes)
      defer {
        pathBytes.deallocate(capacity: MemoryLayout<io_name_t>.size)
      }
      return String(cString: pathBytes)
    }()
    
    guard let device = USBDeviceInterface(service: service) else {
      IOObjectRelease(service)
      return nil // `deinit` is not called
    }
    self.device = device
    
    do {
      descriptor = try BBBUSBDevice.requestDeviceDescriptor(device: device)
      // FIXME: iterate by descriptor.bNumConfigurations
      configurationDescriptor = try BBBUSBDevice.requestConfigurationDescriptor(device: device)
    }
    catch {
      IOObjectRelease(service)
      return nil // `deinit` is not called
    }
  }
  
  private class func requestDeviceDescriptor(device: USBDeviceInterface) throws -> BBBUSBDeviceDescriptor {
    return try withBridgingIOReturnError {
      var rawDevDesc = IOUSBDeviceDescriptor()
      var request = IOUSBDevRequest()
      request.bmRequestType = DeviceRequestRequestType.requestType(.toHost, .standard, .device).rawValue
      request.bRequest = DeviceRequestParticularRequest.getDescriptor.rawValue
      request.wValue = UInt16(USBDescriptorType.device.rawValue) << 8
      request.wIndex = 0
      request.wLength = 18
      request.pData = UnsafeMutableRawPointer(&rawDevDesc)
      try device.deviceRequest(&request)
      
      var devDesc = BBBUSBDeviceDescriptor()
      devDesc.bLength = rawDevDesc.bLength
      devDesc.bDescriptorType = rawDevDesc.bDescriptorType
      devDesc.bcdUSB = rawDevDesc.bcdUSB
      devDesc.bDeviceClass = rawDevDesc.bDeviceClass
      devDesc.bDeviceSubClass = rawDevDesc.bDeviceSubClass
      devDesc.bDeviceProtocol = rawDevDesc.bDeviceProtocol
      devDesc.bMaxPacketSize0 = rawDevDesc.bMaxPacketSize0
      devDesc.idVendor = rawDevDesc.idVendor
      devDesc.idProduct = rawDevDesc.idProduct
      devDesc.bcdDevice = rawDevDesc.bcdDevice
      devDesc.iManufacturer = rawDevDesc.iManufacturer
      devDesc.iProduct = rawDevDesc.iProduct
      devDesc.iSerialNumber = rawDevDesc.iSerialNumber
      devDesc.bNumConfigurations = rawDevDesc.bNumConfigurations
      if devDesc.iManufacturer != 0 {
        devDesc.manufacturerString = try device.getStringDescriptor(at: devDesc.iManufacturer)
      }
      if devDesc.iProduct != 0 {
        devDesc.productString = try device.getStringDescriptor(at: devDesc.iProduct)
      }
      if devDesc.iSerialNumber != 0 {
        devDesc.serialNumberString = try device.getStringDescriptor(at: devDesc.iSerialNumber)
      }
      return devDesc
    }
  }
  
  private class func requestConfigurationDescriptor(device: USBDeviceInterface) throws -> BBBUSBConfigurationDescriptor {
    return try withBridgingIOReturnError {
      var rawConfigDesc = IOUSBConfigurationDescriptor()
      var request = IOUSBDevRequest()
      request.bmRequestType = DeviceRequestRequestType.requestType(.toHost, .standard, .device).rawValue
      request.bRequest = DeviceRequestParticularRequest.getDescriptor.rawValue
      request.wValue = UInt16(USBDescriptorType.configuration.rawValue) << 8
      request.wIndex = 0
      request.wLength = 9
      request.pData = UnsafeMutableRawPointer(&rawConfigDesc)
      try device.deviceRequest(&request)
      
      var configDesc = BBBUSBConfigurationDescriptor()
      configDesc.bLength = rawConfigDesc.bLength
      configDesc.bDescriptorType = rawConfigDesc.bDescriptorType
      configDesc.wTotalLength = rawConfigDesc.wTotalLength
      configDesc.bNumInterfaces = rawConfigDesc.bNumInterfaces
      configDesc.bConfigurationValue = rawConfigDesc.bConfigurationValue
      configDesc.iConfiguration = rawConfigDesc.iConfiguration
      configDesc.bmAttributes = rawConfigDesc.bmAttributes
      configDesc.bMaxPower = rawConfigDesc.MaxPower
      if configDesc.iConfiguration != 0 {
        configDesc.configurationString = try device.getStringDescriptor(at: configDesc.iConfiguration)
      }
      
      if configDesc.wTotalLength > 9 {
        var configDescBytes = [UInt8](repeating: 0, count: Int(configDesc.wTotalLength))
        request.wLength = configDesc.wTotalLength
        request.pData = UnsafeMutableRawPointer(&configDescBytes[0])
        try device.deviceRequest(&request)
        
        var ptr = withUnsafePointer(to: &configDescBytes[9]) { $0 }
        var available = Int(configDesc.wTotalLength) - 9
        
        // optional descriptor(s)
        while available >= 2 {
          if ptr[1] == USBDescriptorType.interface.rawValue {
            break // reach interfaceDescriptor
          }
          
          let bLength = Int(ptr[0])
          guard available >= bLength else {
            throw BBBUSBDeviceError.illegalDescriptor
          }
          
          var bytes = [UInt8](repeating: 0, count: bLength)
          for i in 0..<bLength {
            bytes[i] = ptr[i]
          }
          configDesc.descriptors[ptr[1]] = bytes
          ptr = ptr.advanced(by: bLength)
          available -= bLength
        }
        
        // interfaceDescriptors
        for _ in 0..<configDesc.bNumInterfaces {
          guard available >= 9 && ptr[0] == 9 && ptr[1] == USBDescriptorType.interface.rawValue else {
            throw BBBUSBDeviceError.illegalDescriptor
          }
          var ifDesc = BBBUSBInterfaceDescriptor()
          ifDesc.bLength = ptr[0]
          ifDesc.bDescriptorType = ptr[1]
          ifDesc.bInterfaceNumber = ptr[2]
          ifDesc.bAlternateSetting = ptr[3]
          ifDesc.bNumEndpoints = ptr[4]
          ifDesc.bInterfaceClass = ptr[5]
          ifDesc.bInterfaceSubClass = ptr[6]
          ifDesc.bInterfaceProtocol = ptr[7]
          ifDesc.iInterface = ptr[8]
          ptr = ptr.advanced(by: 9)
          available -= 9
          
          // optional descriptor(s)
          while available >= 2 {
            if ptr[1] == USBDescriptorType.endpoint.rawValue {
              break // reach endpointDescriptor
            }
            
            // classSpecificDescriptor
            let bLength = Int(ptr[0])
            guard available >= bLength else {
              throw BBBUSBDeviceError.illegalDescriptor
            }
            
            var bytes = [UInt8](repeating: 0, count: bLength)
            for i in 0..<bLength {
              bytes[i] = ptr[i]
            }
            ifDesc.descriptors[ptr[1]] = bytes
            ptr = ptr.advanced(by: bLength)
            available -= bLength
          }
          
          for _ in 0..<ifDesc.bNumEndpoints {
            guard available >= 7 && ptr[0] == 7 && ptr[1] == USBDescriptorType.endpoint.rawValue else {
              throw BBBUSBDeviceError.illegalDescriptor
            }
            var epDesc = BBBUSBEndpointDescriptor()
            epDesc.bLength = ptr[0]
            epDesc.bDescriptorType = ptr[1]
            epDesc.bEndpointAddress = ptr[2]
            epDesc.bmAttributes = ptr[3]
            epDesc.wMaxPacketSize = UInt16(ptr[4]) | UInt16(ptr[5]) << 8
            epDesc.bInterval = ptr[6]
            ptr = ptr.advanced(by: 7)
            available -= 7
            
            ifDesc.endpoints.append(epDesc)
          }
          
          configDesc.interfaces.append(ifDesc)
        }
        
        if available != 0 {
          throw BBBUSBDeviceError.illegalDescriptor
        }
      }
      
      return configDesc
    }
  }
  
  
  deinit {
    IOObjectRelease(service)
  }
  
  
  public func open() throws {
    let err = device.open()
    if err != kIOReturnSuccess {
      throw BBBUSBDeviceError.IOReturnError(err: Int(err))
    }
  }
  
  public func close() throws {
    let err = device.close()
    if (err == kIOReturnNotOpen) {
      // Ignore
    }
    else if (err != kIOReturnSuccess) {
      throw BBBUSBDeviceError.IOReturnError(err: Int(err))
    }
  }
  
  public func listInterfaces() throws -> [BBBUSBInterface] {
    var iterator = io_iterator_t()
    let err = device.getUSBInterfaceIterator(&iterator)
    if err != kIOReturnSuccess {
      throw BBBUSBDeviceError.IOReturnError(err: Int(err))
    }
    defer {
      IOObjectRelease(iterator)
    }
    
    var interfaces: [BBBUSBInterface] = []
    var interfaceCount = 0
    for service in IOServiceSequence(iterator) {
      let ifDesc = configurationDescriptor.interfaces[interfaceCount] // without range check
      if let interface = BBBUSBInterface(service: service, device: self, descriptor: ifDesc) { // move service
        interfaces.append(interface)
      }
      interfaceCount += 1
    }
    return interfaces
  }
  
  public var description: String {
    get {
      return String(format: "BBBUSBKit.BBBUSBDevice = { name=\"\(name)\", path=\"\(path)\", vendorID=0x%04x, productID=0x%04x }", descriptor.idVendor, descriptor.idProduct)
    }
  }
}
