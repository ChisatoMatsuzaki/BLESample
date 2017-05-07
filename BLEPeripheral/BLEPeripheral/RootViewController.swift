//
//  RootViewController.swift
//  BLEPeripheral
//
//  Created by Chisato Matsuzaki on 2017/05/02.
//  Copyright © 2017年 Chisato Matsuzaki. All rights reserved.
//

import UIKit
import CoreBluetooth

class RootViewController: UIViewController {

    // MARK: * Outlets *
    @IBOutlet weak var advertiseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    // MARK: * Constants *
    fileprivate let serviceUUID = CBUUID(string: "D838EE05-153C-4766-AC8E-C6E2F2FD32AA")
    fileprivate let characteristicUUID = CBUUID(string: "71568DD9-EE17-4DA6-A6E7-BFFB9803AADE")
    
    
    // MARK: * Variables *
    fileprivate var logLists: [String] = []
    fileprivate var peripheralManager: CBPeripheralManager!
    fileprivate var characteristic: CBMutableCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        
        advertiseButton.layer.cornerRadius = 4.0
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.borderColor = UIColor.darkGray.cgColor
        
        // peripheral manager 初期化
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: * Navigation *
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    
    // MARK: * Button Action *
    @IBAction func advertiseButtonDidTap(_ sender: UIButton) {
        if sender.isSelected {
            // -> stop
            peripheralManager.stopAdvertising()
        } else {
            // -> start
            let advertisementData = [CBAdvertisementDataLocalNameKey : "BLE Peripheral device"]
            peripheralManager.startAdvertising(advertisementData)
        }
        sender.isSelected = !sender.isSelected
    }
    
    fileprivate func addService() {
        
        // サービス作成
        let service: CBMutableService = CBMutableService(type: serviceUUID, primary: true)
        
        // キャラクタリスティック作成
        let properties: CBCharacteristicProperties = [.read, .write]
        let permissions: CBAttributePermissions = [.readable, .writeable]
        characteristic = CBMutableCharacteristic(type: characteristicUUID,
                                                 properties: properties,
                                                 value: nil,
                                                 permissions: permissions)
        // サービスにキャラクタリスティックを追加
        service.characteristics = [characteristic]
        
        // ペリフェラルにサービスを追加
        peripheralManager.add(service)

        // キャラクタリスティックにデータをセット
        // add serviceの前にやるとエラーになる
//        let dic = ["key1" : "ひとつめのキーの値",
//                   "key2" : "ふたつめのキーの値"]
//        let data = NSKeyedArchiver.archivedData(withRootObject: dic)
        let str = "value1,値２"
        let data = str.data(using: .utf8)
//        let data = Data(base64Encoded: "value1,値２")
        characteristic.value = data

    }
}

// MARK: - * UITableViewDataSource *
extension RootViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! LogCell
        cell.label.text = logLists[indexPath.row]
        return cell
    }
}

// MARK: - * UITableViewDelegate *
extension RootViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 35.0
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - * CBPeripheralDelegate *
extension RootViewController: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            advertiseButton.isEnabled = true
            advertiseButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
            addService()
        case .poweredOff:
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if error != nil {
            print("サービス追加失敗")
            print(error ?? "unknown")
        } else {
            print("サービス追加成功")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("Readリクエスト受信")
        print("service UUID : \(request.characteristic.service.uuid.uuidString)")
        print("charcteristic UUID : \(request.characteristic.uuid.uuidString)")
        print("value : \(String(describing: request.characteristic.value))")
        
        // 応答を返す
        if request.characteristic.uuid.isEqual(characteristic.uuid) {
//            let dic = NSKeyedUnarchiver.unarchiveObject(with: self.characteristic.value!) as! Dictionary<String, String>

            request.value = self.characteristic.value
//            let dic = ["key1" : "ひとつめのキーの値",
//                       "key2" : "ふたつめのキーの値"]
//            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
//            request.value = data

            peripheralManager.respond(to: request, withResult: .success)
        } else {
            print("characteristic UUIDが違う")
            peripheralManager.respond(to: request, withResult: .requestNotSupported)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Writeリクエストを受信: \(requests.count)件")
        for request in requests {
            if request.characteristic.uuid.isEqual(self.characteristic.uuid) {
                self.characteristic.value = request.value

                let str = String(bytes: self.characteristic.value!, encoding: String.Encoding.utf8) ?? ""
                print("value : \(str)")

            }
        }
        peripheralManager.respond(to: requests[0], withResult: .success)
    }
}
