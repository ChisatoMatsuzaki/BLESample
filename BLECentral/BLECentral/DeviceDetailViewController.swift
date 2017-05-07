//
//  DeviceDetailViewController.swift
//  BLECentral
//
//  Created by Chisato Matsuzaki on 2017/05/04.
//  Copyright © 2017年 Chisato Matsuzaki. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceDetailViewController: UIViewController {

    // MARK: * Struct *
    struct CellInfo {
        let cellIdentifier: String
        let uuid: String
    }
    
    // MARK: * Outlets *
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceUUIDLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: * Constants *
    fileprivate let serviceCellIdentifier = "serviceCell"
    fileprivate let characteristicCellIdentifier = "characteristicCell"
    
    // MARK: * Variables *
    public var peripheral: CBPeripheral!
    fileprivate var cellLists: [CellInfo] = []

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectButton.isEnabled = true
        connectButton.layer.cornerRadius = 4.0
        connectButton.layer.borderWidth = 1.0
//        connectButton.layer.borderColor = UIColor.darkGray.cgColor
        connectButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CentralManager.sharedInstance.centralManager.delegate = self
        
        deviceNameLabel.text = peripheral.name
        deviceUUIDLabel.text = peripheral.identifier.uuidString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: * Navigation *
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    @IBAction func connectButtonDidTap(_ sender: UIButton) {
        if sender.isSelected {
            // -> disconnect
            print("disconnect tap")
            
        } else {
            // -> connect
            print("connect tap")
            CentralManager.sharedInstance.centralManager.connect(peripheral, options: nil)
        }
    }
    
    @IBAction func backButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - * UITableViewDataSource *
extension DeviceDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellLists[indexPath.row].cellIdentifier == serviceCellIdentifier {
            let cell = tableView.dequeueReusableCell(withIdentifier: serviceCellIdentifier, for: indexPath) as! ServiceCell
            cell.uuidLabel.text = cellLists[indexPath.row].uuid
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: characteristicCellIdentifier, for: indexPath) as! CharacteristicCell
            cell.uuidLabel.text = cellLists[indexPath.row].uuid
            return cell
        }
    }
}

// MARK: - * UITableViewDelegate *
extension DeviceDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - * CBCentralManagerDelegate *
extension DeviceDetailViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("power on")
            connectButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
            connectButton.isEnabled = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続成功")
        connectButton.isSelected = true
        
        // サービス検索開始
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("切断")
        connectButton.isSelected = false
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗")
    }
}

// MARK: - * CBPeripheralDelegate *
extension DeviceDetailViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")

        print(service)
        cellLists.append(CellInfo(cellIdentifier: serviceCellIdentifier, uuid: service.uuid.uuidString))

        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.uuid.isEqual(CentralManager.sharedInstance.characteristicUUID)
                && ((characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0) {
                print("value read")
                peripheral.readValue(for: characteristic)
            }
            
            cellLists.append(CellInfo(cellIdentifier: characteristicCellIdentifier, uuid: characteristic.uuid.uuidString))
            self.tableView.reloadData()
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Read 成功")
        print("UUID : \(characteristic.uuid.uuidString)")
        let str = String(bytes: characteristic.value!, encoding: String.Encoding.utf8) ?? ""
        print(str)
        
        let str2 = "受け取ったよ！"
        let data = str2.data(using: .utf8)
        
        peripheral.writeValue(data!, for: characteristic, type: .withResponse)

        
//        if let data = characteristic.value {
//            var bytes = Array(repeating: 0 as UInt8, count:someData.count/MemoryLayout<UInt8>.size)
//            
//            data.copyBytes(to: &bytes, count:data.count)
//            let data16 = bytes.map { UInt16($0) }
//            wavelength = 256 * data16[1] + data16[0]
//        }
//        
//        
//        guard let data = characteristic.value else {
//            print("value is nil")
//            return
//        }
////        let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as! Dictionary<String, String>
//        
//        let str = String(data: characteristic.value, enco
//        print(dic)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Write成功")
    }
}
