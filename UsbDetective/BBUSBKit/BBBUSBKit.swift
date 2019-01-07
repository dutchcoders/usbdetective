//
//  BBBUSBKit.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

import Foundation
//import BBBUSBKitPrivate

#if false // because "Swift Compiler Error" has occured
extension io_iterator_t: Sequence {
  // Swift Compiler Error: Method 'makeIterator()' must be declared public because it matches a requirement in public protocol 'Sequence'
  // Swift Compiler Error: Method must be declared internal because its result uses a internal type
  func makeIterator() -> IOServiceGenerator {
    return IOServiceGenerator(self)
  }
}
#else
class IOServiceSequence: Sequence {
  let iterator: io_iterator_t
  
  init(_ iterator: io_iterator_t) {
    self.iterator = iterator
  }
  
  func makeIterator() -> IOServiceGenerator {
    return IOServiceGenerator(iterator)
  }
}
#endif

class IOServiceGenerator: IteratorProtocol {
  let iterator: io_iterator_t
  
  init(_ iterator: io_iterator_t) {
    self.iterator = iterator
  }
  
  func next() -> io_service_t? {
    let service = IOIteratorNext(iterator)
    if service == 0 {
      return nil
    }
    return service
  }
}

func withBridgingIOReturnError<T>(block: () throws -> T) throws -> T {
  do {
    return try block()
  }
  catch let error as NSError where error.domain == kBBBUSBKitIOReturnErrorDomain {
    throw BBBUSBDeviceError.IOReturnError(err: error.code)
  }
}
