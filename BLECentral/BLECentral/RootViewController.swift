//
//  RootViewController.swift
//  BLECentral
//
//  Created by Chisato Matsuzaki on 2017/05/02.
//  Copyright © 2017年 Chisato Matsuzaki. All rights reserved.
//

import UIKit
import CoreBluetooth

class RootViewController: UIViewController {

    // MARK: * Outlets *
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var scanOptionCheckButton: UIButton!
    @IBOutlet weak var scanOptionLabelButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!

    // MARK: * Constants *
    
    // MARK: * Variables *
    
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        scanButton.layer.cornerRadius = 4.0
        scanButton.layer.borderWidth = 1.0
        scanButton.layer.borderColor = UIColor.darkGray.cgColor
        
        
        // central manager 初期化
        CentralManager.sharedInstance.centralManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: * Navigation *
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        scanButton.isSelected = false
        CentralManager.sharedInstance.centralManager.stopScan()

        if segue.identifier == "toDetail" {
            let vc = segue.destination as! DeviceDetailViewController
            vc.peripheral = sender as! CBPeripheral!
        }
    }

    
    // MARK: * Button Action *
    @IBAction func scanButtonDidTap(_ sender: UIButton) {
        if sender.isSelected {
            // -> stop
            CentralManager.sharedInstance.centralManager.stopScan()
        } else {
            // -> start
            CentralManager.sharedInstance.deviceLists.removeAll()
            
            if scanOptionCheckButton.isSelected {
                print("特定のサービスのみ")
                CentralManager.sharedInstance.centralManager.scanForPeripherals(withServices: [CentralManager.sharedInstance.serviceUUID],
                                                                                options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
            } else {
                print("全てのペリフェラル")
                CentralManager.sharedInstance.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func scanOptionButtonDidTap(_ sender: UIButton) {
        scanOptionCheckButton.isSelected = !scanOptionCheckButton.isSelected
        scanOptionLabelButton.isSelected = !scanOptionLabelButton.isSelected
    }
    
    
}

// MARK: - * UITableViewDataSource *
extension RootViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CentralManager.sharedInstance.deviceLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! DeviceCell
        cell.nameLabel.text = CentralManager.sharedInstance.deviceLists[indexPath.row].peripheral.name
        cell.uuidLabel.text = CentralManager.sharedInstance.deviceLists[indexPath.row].peripheral.identifier.uuidString
        cell.rssiLabel.text = "\(CentralManager.sharedInstance.deviceLists[indexPath.row].rssi)dB"
        return cell
    }
}

// MARK: - * UITableViewDelegate *
extension RootViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: CentralManager.sharedInstance.deviceLists[indexPath.row].peripheral)
    }
}

// MARK: - * CBCentralManagerDelegate *
extension RootViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            break
        case .poweredOn:
            scanButton.layer.borderColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor
            scanButton.isEnabled = true
        case .resetting:
            break
        case .unauthorized:
            break
        case .unknown:
            break
        case .unsupported:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if scanOptionCheckButton.isSelected && peripheral.name == nil { return }
        CentralManager.sharedInstance.deviceLists.append(CentralManager.DeviceInfo(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI))
        self.tableView.reloadData()
    }

}
