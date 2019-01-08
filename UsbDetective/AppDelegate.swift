// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
//   regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
// under the License.

// https://developer.apple.com/library/archive/samplecode/USBPrivateDataSample/Listings/USBPrivateDataSample_c.html

import Cocoa
import USBDeviceSwift
import AppKit

import IOKit
import IOKit.hid
import IOKit.usb

class USBDevice {
  var Name: String = ""
  var PrimaryUsage: Int = 0
  var Category: String = ""
  var Manufacturer: String = ""
  var TransportKey: String = ""
  var ManufacturerKey: String = ""
  var ProductID: Int = 0
  var VendorID: Int = 0
  var SerialNumber: String = ""
  var UniqueIdentifier: Int = 0
  
  init(device: IOHIDDevice) {
    self.Name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "HID Device"
    self.VendorID = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int ?? 0
    self.ProductID = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int ?? 0
    self.UniqueIdentifier = IOHIDDeviceGetProperty(device, kIOHIDUniqueIDKey as CFString) as? Int ?? 0
    self.TransportKey = IOHIDDeviceGetProperty(device, kIOHIDTransportKey as CFString) as? String ?? ""
    self.ManufacturerKey = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String ?? ""
    self.SerialNumber = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString) as? String ?? ""
    self.PrimaryUsage = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int ?? 0
    // self.ReportDescriptorKey = IOHIDDeviceGetProperty(device, kIOHIDReportDescriptorKey as CFString) as? String ?? ""
    // self.LocationIDKey = IOHIDDeviceGetProperty(device, kIOHIDLocationIDKey as CFString) as? String ?? ""
    // self.ModelNumberKey = IOHIDDeviceGetProperty(device, kIOHIDModelNumberKey as CFString) as? String ?? ""
  }
  
  func Signature() -> String {
      return "\(self.Name)#\(self.VendorID)#\(self.ProductID)#\(self.SerialNumber)#\(self.TransportKey)#\(self.ManufacturerKey)"
  }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  
  var devices: [Int: USBDevice] = [:]

  let hidTypes = [
    1: "Pointer",
    2: "Mouse",
    4: "Joystick",
    5: "Game Pad",
    6: "Keyboard",
    7: "Keypad",
    8: "Multi-axis Controller",
  ]
  
  lazy var newDeviceWindowController: NSWindowController = {
    return (NSStoryboard(name: "Main",bundle: nil).instantiateController(withIdentifier: "NewDevice") as? NSWindowController)!
  }()

  lazy var aboutWindowController: NSWindowController = {
    return (NSStoryboard(name: "Main",bundle: nil).instantiateController(withIdentifier: "About") as? NSWindowController)!
  }()
  
  lazy var manager: IOHIDManager = {
    return IOHIDManagerCreate(nil, 0)
  }()
  
  let aboutItem: NSMenuItem = NSMenuItem(title: "About", action: #selector(doAbout), keyEquivalent: "")
  let resetItem: NSMenuItem = NSMenuItem(title: "Reset", action: #selector(doReset), keyEquivalent: "")
  let quitItem: NSMenuItem = NSMenuItem(title: "Quit", action: #selector(doQuit), keyEquivalent: "")

  @objc func doAbout(sender: AnyObject){
    NSApplication.shared.runModal(for: aboutWindowController.window!)
    aboutWindowController.close()
  }
  
  @objc func doQuit(sender: AnyObject){
    NSApplication.shared.terminate(nil)
  }

  @objc func doReset(sender: AnyObject){
    let whitelist = [String]()
    UserDefaults.standard.set(whitelist, forKey: "whitelist")
    
    let alert:NSAlert = NSAlert();
    alert.messageText = "USBDetective";
    alert.alertStyle = NSAlert.Style.warning
    alert.informativeText = "USBDetective has been resetted."
    alert.runModal();
  }

  private func updateMenu() {
    statusItem.menu?.removeAllItems()
    
    let keys = devices.keys.sorted { (a, b) -> Bool in
      let nameA = devices[a]!.Name
      let nameB = devices[b]!.Name
      return nameA.compare(nameB) == ComparisonResult.orderedAscending
    }
    
    let types = [
      "Pointer": 1,
      "Mouse": 2,
      "Keyboard ⌨": 6,
    ]
    
    for (name) in types.keys.sorted() {
      let type = types[name]
      
      let newItem : NSMenuItem = NSMenuItem(title:  "\(name)" , action: nil, keyEquivalent: "")
      newItem.indentationLevel = 0
      self.statusItem.menu?.addItem(newItem)
      
      for (key) in keys {
        let device = devices[key]!;
        
        let name = device.Name
        let primaryUsageKey = device.PrimaryUsage
        
        if (primaryUsageKey != type) {
          continue
        }
        
        let newItem : NSMenuItem = NSMenuItem(title:  "\u{2022} \(name)" , action: nil, keyEquivalent: "")
        newItem.indentationLevel = 1
        newItem.representedObject = device
        self.statusItem.menu?.addItem(newItem)
      }
    }
    
    let newItem : NSMenuItem = NSMenuItem(title:  "Other" , action: nil, keyEquivalent: "")
    newItem.indentationLevel = 0
    self.statusItem.menu?.addItem(newItem)
    
    for (key) in keys {
      let device = devices[key]!;
      
      let name = device.Name
      let primaryUsageKey = device.PrimaryUsage
      
      if (types.contains(where: { (arg0) -> Bool in
        let (_, value) = arg0
        return  (value == primaryUsageKey)
      })) {
        continue
      }
      
      let newItem : NSMenuItem = NSMenuItem(title:  "\u{2022} \(name)" , action: nil, keyEquivalent: "")
      newItem.indentationLevel = 1
      newItem.representedObject = device
      self.statusItem.menu?.addItem(newItem)
    }

    statusItem.menu?.addItem(NSMenuItem.separator())
    statusItem.menu?.addItem(resetItem)
    statusItem.menu?.addItem(NSMenuItem.separator())
    statusItem.menu?.addItem(aboutItem)
    statusItem.menu?.addItem(quitItem)
  }
  
  private func removedDevice(_ device: IOHIDDevice) {
    let uniqueIdentifier = IOHIDDeviceGetProperty(device, kIOHIDUniqueIDKey as CFString) as? Int ?? 0
    let ub = devices[uniqueIdentifier]!

    defer {
      devices.removeValue(forKey: uniqueIdentifier)
      self.updateMenu()
    }
    
    let whitelist = UserDefaults.standard.array(forKey: "whitelist") as? [String] ?? [String]()
    if (whitelist.contains(ub.Signature())) {
      return
    }
    
    let usageKeyText = hidTypes[ub.PrimaryUsage] ?? "Unknown Device(\(ub.PrimaryUsage))"

    let notification = NSUserNotification()
    // notification.identifier = "unique-id"
    notification.title = "Device removal detected: \(ub.Name)"
    notification.subtitle = ""
    notification.informativeText = "Removal of device (\(usageKeyText)) interface has been detected. Usage=\(usageKeyText) Vendor: 0x\(String(format:"0x%04X", ub.VendorID)) Product: \(String(format:"0x%04X", ub.ProductID)) Serial=\(ub.SerialNumber) "
    
    notification.soundName = NSUserNotificationDefaultSoundName
    notification.contentImage = NSImage(contentsOf: NSURL(string: "https://placehold.it/300")! as URL)
    
    // Manually display the notification
    let notificationCenter = NSUserNotificationCenter.default
    notificationCenter.deliver(notification)
  }
  
  private func foundDevice(_ device: IOHIDDevice) {
    var whitelist = UserDefaults.standard.array(forKey: "whitelist") as? [String] ?? [String]()

    let ub = USBDevice(device: device)
    
    defer {
      devices[ub.UniqueIdentifier] = ub
      self.updateMenu()
    }

    if (whitelist.contains(ub.Signature())) {
      return
    }

    let viewController = newDeviceWindowController.contentViewController as! NewDeviceViewController
    
    viewController.representedObject = ub
    
    switch (newDeviceWindowController as! NewDeviceWindowController).runModal() {
    case .Whitelist:
      whitelist.append(ub.Signature())
      UserDefaults.standard.set(whitelist, forKey: "whitelist")
      break
    case .Close:
      break
    }
    
    newDeviceWindowController.close()
    
    let usageKeyText = hidTypes[ub.PrimaryUsage] ?? "Unknown Device(\(ub.PrimaryUsage))"

    let notification = NSUserNotification()
    notification.identifier = "\(ub.UniqueIdentifier)"
    notification.title = "New device detected: \(ub.Name)"
    notification.subtitle = ""
    notification.informativeText = "New device (\(usageKeyText)) interface has been detected. Usage=\(usageKeyText) Vendor: 0x\(String(format:"0x%04X", ub.VendorID)) Product: \(String(format:"0x%04X", ub.ProductID)) Serial=\(ub.SerialNumber) "
    
    // notification.soundName = NSUserNotificationDefaultSoundName
    // notification.contentImage = NSImage(contentsOf: NSURL(string: "https://placehold.it/300")! as URL)
    
    // Manually display the notification
    let notificationCenter = NSUserNotificationCenter.default
    notificationCenter.deliver(notification)
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    IOHIDManagerSetDeviceMatching(manager, nil)
    
    IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, result, other, device in
      let selfPointer = unsafeBitCast(context, to: AppDelegate.self)
      selfPointer.foundDevice(device)
    }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

    IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, result, other, device in
      let selfPointer = unsafeBitCast(context, to: AppDelegate.self)
      selfPointer.removedDevice(device)
    }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    
    IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    
    let result = IOHIDManagerOpen(manager, 0)
    guard result == kIOReturnSuccess else {
      let alert:NSAlert = NSAlert();
      alert.messageText = "Could not open IOHIDManager";
      alert.alertStyle = NSAlert.Style.warning
      alert.informativeText = "IOHIDManagerOpen returned error: \(result)"
      alert.runModal();
      return
    }

    guard statusItem.button != nil else {
      NSLog("Can't get menuButton")
      return
    }
    
    statusItem.highlightMode = true
    statusItem.menu = NSMenu()
    
    let newItem : NSMenuItem = NSMenuItem(title:  "Loading device list..." , action: nil, keyEquivalent: "")
    self.statusItem.menu?.addItem(newItem)

    statusItem.menu?.addItem(NSMenuItem.separator())
    statusItem.menu?.addItem(quitItem)
    
    // nice icon here
    statusItem.button?.title = "Usb 🔍"
    
    updateMenu()
    
    let matchingDict = IOServiceMatching(kIOUSBDeviceClassName)
    
    let notifyPort = IONotificationPortCreate(kIOMasterPortDefault)

    let  notifyQueue = DispatchQueue.global()// (label: "com.georgwacker.discrotate.notifyQueue")
    IONotificationPortSetDispatchQueue(notifyPort, notifyQueue)
   
    let selfPtr = Unmanaged.passUnretained(self).toOpaque()
    
    var newDevicesIterator: io_iterator_t = 0;

    let usbDeviceAppeared: IOServiceMatchingCallback = { (refcon, iterator) in
      print("Matching USB device appeared")
    }

    // https://github.com/georgwacker/DiscRotate/blob/f13156c72595160f752ae4d952e47ff92f9d31b5/DiscRotate/OpticalMediaDetector.swift
    // https://pastebin.com/icyAAUzZ
    IOServiceAddMatchingNotification(notifyPort, kIOMatchedNotification, matchingDict, usbDeviceAppeared, selfPtr, &newDevicesIterator)
    
    var lostDevicesIterator: io_iterator_t = 0;
    
    let usbDeviceDisappeared: IOServiceMatchingCallback = { (refcon, iterator) in
      print("Matching USB device disappeared")
    }
    
    IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, matchingDict, usbDeviceDisappeared, selfPtr, &lostDevicesIterator)
    
    _ = self.listDevices()
 }
  
  public func listDevices() -> [String]? {
    var iterator: io_iterator_t = io_iterator_t()
    
    let matchingInformation = IOServiceMatching(kIOUSBDeviceClassName)
    let kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingInformation, &iterator)
    if kr != kIOReturnSuccess {
      print("Error")
      return nil
    }
    defer {
      IOObjectRelease(iterator)
    }
    
    var devices: [String] = []
    
    for service in IOServiceSequence(iterator) {
      if let device = BBBUSBDevice(service: service) { // move service
        devices.append(device.name)
      }
    }
    
    return devices
  }

  
  func applicationWillTerminate(_ aNotification: Notification) {
    IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    IOHIDManagerClose(manager, 0)
  }
}

