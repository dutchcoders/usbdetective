//
//  BBBUSBEndpoint.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/12/03.
//
//

import Cocoa

public class BBBUSBEndpoint {
  
  public enum Direction {
    case out
    case `in`
    
    init(bEndpointAddressBit7: UInt8) {
      switch bEndpointAddressBit7 {
      case 0b0:
        self = .out
      case 0b1:
        self = .in
      default:
        fatalError()
      }
    }
  }
  
  public enum TransferType {
    case control
    case isochronous
    case bulk
    case interrupt
    
    init(bmAttributesBits1_0: UInt8) {
      switch bmAttributesBits1_0 {
      case 0b00:
        self = .control
      case 0b01:
        self = .isochronous
      case 0b10:
        self = .bulk
      case 0b11:
        self = .interrupt
      default:
        fatalError()
      }
    }
  }
  
  public let descriptor: BBBUSBEndpointDescriptor
  public let direction: Direction
  public let transferType: TransferType
  weak var interface: BBBUSBInterface!
  
  init(interface: BBBUSBInterface, descriptor: BBBUSBEndpointDescriptor) {
    self.interface = interface
    self.descriptor = descriptor
    direction = Direction(bEndpointAddressBit7: descriptor.bEndpointAddress >> 7)
    transferType = TransferType(bmAttributesBits1_0: descriptor.bmAttributes & 0x03)
  }
  
}
