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

import Cocoa

class NewDeviceViewController: NSViewController {
  @IBOutlet weak var Category: NSTextField!
  @IBOutlet weak var VendorIdentifier: NSTextField!
  @IBOutlet weak var ProductIdentifier: NSTextField!
  @IBOutlet weak var Serial: NSTextField!
  @IBOutlet weak var Name: NSTextField!
  @IBOutlet weak var Manufacturer: NSTextField!
  
  let hidTypes = [
    1: "Pointer",
    2: "Mouse",
    4: "Joystick",
    5: "Game Pad",
    6: "Keyboard",
    7: "Keypad",
    8: "Multi-axis Controller",
    ]
  
  let vendors = [
    0x05AC: "Apple, Inc.",
    ]

  let products = [
    0x030E: "MC380Z/A [Magic Trackpad]"
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
      Name.stringValue = (representedObject as! USBDevice).Name

      let primaryUsageKey = (representedObject as! USBDevice).PrimaryUsage
      let usageKeyText = hidTypes[primaryUsageKey] ?? "Unknown Device (\(primaryUsageKey))"
      Category.stringValue = usageKeyText
      
      let vendorID = (representedObject as! USBDevice).VendorID
      VendorIdentifier.stringValue = "\(vendors[vendorID] ?? "Unknown") (\(String(format:"0x%04X", vendorID)))"
      
      let productID = (representedObject as! USBDevice).ProductID
      ProductIdentifier.stringValue = "\(products[productID] ?? "Unknown") (\(String(format:"0x%04X", productID)))"
      Serial.stringValue = "\((representedObject as! USBDevice).SerialNumber)"
      
      Manufacturer.stringValue = "\((representedObject as! USBDevice).Manufacturer)"
      
      self.view.window!.title = "USB Detective 🔍"
    }
  }
  
  @IBAction func whitelistButton(_ sender: Any) {
    let application = NSApplication.shared
    application.stopModal(withCode: NSApplication.ModalResponse(ModalResult.Whitelist.rawValue))
  }
  
  @IBAction func dismiss(_ sender: Any) {
    let application = NSApplication.shared
    application.stopModal()
  }
}

