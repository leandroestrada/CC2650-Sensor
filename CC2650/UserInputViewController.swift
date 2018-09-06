//
//  UserInputViewController.swift
//  CC2650
//
//  Created by le on 06/09/2018.
//  Copyright © 2018 LeandroEstrada. All rights reserved.
//

@IBOutlet private(set) weak var sensorID: UITextField!
@IBOutlet private weak var phoneNumber: UITextField!
@IBOutlet private weak var lumosLabel: UILabel!
@IBOutlet private weak var timeScan: UILabel!
@IBOutlet private(set) weak var luxometerSensor: UISlider!
@IBOutlet private(set) weak var timeScanSensor: UISlider!

@IBOutlet weak var luxometerSensorMax: UISlider!

@IBOutlet weak var luxometerSensorMaxLabel: UILabel!


private(set) var numberToSend: String = ""
private(set) var sensorId: String = ""

var pickerID = UIPickerView()

let ID : [String] = []
