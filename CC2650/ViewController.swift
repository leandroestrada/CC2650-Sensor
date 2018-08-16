//
//  ViewController.swift
//  CC2650
//
//  Created by le on 15/08/2018.
//  Copyright © 2018 LeandroEstrada. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    @IBOutlet var lightText: UIView!
    
    @IBOutlet weak var temperatureText: UILabel!
    
    @IBOutlet weak var humidityText: UILabel!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print ("scanning...")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.contains("SensorTag") == true {
            print (peripheral.name ?? "no name")
            centralManager.stopScan()
            print (advertisementData)
            central.connect(peripheral, options: nil)
            myPeripheral = peripheral
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print ("connected \(peripheral.name)")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
}

