//
//  ViewController.swift
//  CC2650
//
//  Created by le on 15/08/2018.
//  Copyright © 2018 LeandroEstrada. All rights reserved.
//

import UIKit
import CoreBluetooth

let svcHumidity = CBUUID.init(string: "F000AA20-0451-4000-B000-000000000000")
let svcTemperature = CBUUID.init(string: "F000AA00-0451-4000-B000-000000000000")
let svcLight = CBUUID.init(string: "F000AA70-0451-4000-B000-000000000000")
let svcAccelerometer = CBUUID.init(string: "F000AA10-0451-4000-B000-000000000000")
let svcBarometer = CBUUID.init(string: "F000AA40-0451-4000-B000-000000000000")
let svcMovement = CBUUID.init(string: "F000AA80-0451-4000-B000-000000000000")
let svcMagnetometer = CBUUID.init(string: "F000AA30-0451-4000-B000-000000000000")

let temperData = CBUUID.init(string: "F000AA01-0451-4000-B000-000000000000")
let temperConfig = CBUUID.init(string: "F000AA02-0451-4000-B000-000000000000")

let accelerometerData = CBUUID.init(string: "F000AA11-0451-4000-B000-000000000000")
let accelerometerConfig = CBUUID.init(string: "F000AA12-0451-4000-B000-000000000000")

let magnetometerData = CBUUID.init(string: "F000AA31-0451-4000-B000-000000000000")
let magnetometerConfig = CBUUID.init(string: "F000AA32-0451-4000-B000-000000000000")

let barometerData = CBUUID.init(string: "F000AA41-0451-4000-B000-000000000000")
let barometerConfig = CBUUID.init(string: "F000AA42-0451-4000-B000-000000000000")

let movementData = CBUUID.init(string: "F000AA81-0451-4000-B000-000000000000")
let movementConfig = CBUUID.init(string: "F000AA82-0451-4000-B000-000000000000")
let movementPeriod = CBUUID.init(string: "F000AA83-0451-4000-B000-000000000000")

let charHumidityData = CBUUID.init(string: "F000AA21-0451-4000-B000-000000000000" )
let charHumidityConfig = CBUUID.init(string: "F000AA22-0451-4000-B000-000000000000")

let charLightConfig = CBUUID.init(string: "F000AA72-0451-4000-B000-000000000000")
let charLightData = CBUUID.init(string: "F000AA71-0451-4000-B000-000000000000")


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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for svc in services {
                if svc.uuid == svcLight {
                    print (svc.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
                if svc.uuid == svcHumidity{
                    print(svc.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
                if svc.uuid == svcBarometer{
                    print(svc.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
                if svc.uuid == svcMovement{
                    print(svc.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
                if svc.uuid == svcTemperature{
                    print(svc.uuid.uuidString)
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
                
            }
            
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let chars = service.characteristics {
            for char in chars {
                print (char.uuid.uuidString)
                if char.uuid == charHumidityConfig{
                    if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
                    }
                    else{
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
                    }
                }
                else if char.uuid == charHumidityData{
                    checkHumidity(curChar: char)
                }
                    //TEMPERATURA
                else if char.uuid == temperConfig {
                    if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
                    }
                    else {
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
                    }
                }
                    //GIROSCOPIO
                else if char.uuid == movementConfig{
                    
                    // FF - with WOM
                    // 7F - all sensors on, 03 - 16 G
                    let bytes : [UInt8] = [ 0x7F, 0x03 ]
                    let data = Data(bytes:bytes)
                    
                    peripheral.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
                    
                }
                else if char.uuid == movementPeriod {
                    print ("Changing period")
                    let bytes : [UInt8] = [ currentPeriod ]
                    let data = Data(bytes:bytes)
                    peripheral.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
                }
                    
                else if char.uuid == movementData{
                    checkMovement(curChar: char)
                }
                    //                else if char.uuid == gyroscopeData {
                    //                    checkGyroscope(curChar: char)
                    //                }
                    
                    //BAROMETRO
                else if char.uuid == barometerData{
                    if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
                    }
                    else{
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
                    }
                }
                    //LUZ
                else if char.uuid == charLightConfig {
                    if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
                    }
                    else {
                        peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
                    }
                }
                else if char.uuid == charLightData {
                    checkLight(curChar: char)
                }
            }
        }
    }
    
    //*************************************INTERVALS********************************************
    
    
    func checkLight(curChar : CBCharacteristic) {
        Timer.scheduledTimer(withTimeInterval: pickerSelecionado, repeats: true) { (timer) in
            self.myPeripheral!.readValue(for: curChar)
            print(self.pickerSelecionado)
        }
    }
    
    
    func checkMovement(curChar : CBCharacteristic){
        Timer.scheduledTimer(withTimeInterval: pickerSelecionado, repeats: true) { (timer) in
            self.myPeripheral!.readValue(for: curChar)
            print(self.pickerSelecionado)
            
        }
    }
    
    func checkHumidity(curChar : CBCharacteristic){
        Timer.scheduledTimer(withTimeInterval: pickerSelecionado, repeats: true) { (timer) in
            self.myPeripheral!.readValue(for: curChar)
            print(self.pickerSelecionado)
            
        }
    }
    
    
}
