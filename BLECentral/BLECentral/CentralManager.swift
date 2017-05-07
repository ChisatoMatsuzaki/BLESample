//
//  CentralManager.swift
//  BLECentral
//
//  Created by Chisato Matsuzaki on 2017/05/02.
//  Copyright © 2017年 Chisato Matsuzaki. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralManager: NSObject {

    static let sharedInstance = CentralManager()
    
    // MARK: * Structs *
    struct DeviceInfo {
        let peripheral: CBPeripheral
        let advertisementData: [String: Any]
        let rssi: NSNumber
    }
    
    let serviceUUID = CBUUID(string: "D838EE05-153C-4766-AC8E-C6E2F2FD32AA")
    let characteristicUUID = CBUUID(string: "71568DD9-EE17-4DA6-A6E7-BFFB9803AADE")
    
    public var centralManager = CBCentralManager()
    public var deviceLists: [DeviceInfo] = []
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: nil, queue: nil)
    }
    
}

