//
//  SettingsViewController.swift
//  yolov3
//
//  Created by Alexander on 19/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var iouSlider: UISlider!
  @IBOutlet weak var confSlider: UISlider!
  @IBOutlet weak var modelPicker: UIPickerView!
  @IBOutlet weak var iouLabel: UILabel!
  @IBOutlet weak var confLabel: UILabel!
  
  var pickerData: [String] = []
  
  weak var settings: Settings!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    settings = Settings.shared
    iouSlider.minimumValue = 0
    iouSlider.maximumValue = 1
    confSlider.minimumValue = 0
    confSlider.maximumValue = 1
    iouSlider.value = settings.iouThreshold
    iouLabel.text = String(format: "%.2f", iouSlider.value)
    confSlider.value = settings.confidenceThreshold
    confLabel.text = String(format: "%.2f", confSlider.value)
    
    pickerData = ["YOLOv3-416", "YOLOv3-tiny"]

        // Do any additional setup after loading the view.
  }
  
  @IBAction func save() {
    
  }
  
  @IBAction func restoreDefault() {
    
  }
  
  @IBAction func iouChanged() {
    print(iouSlider.value)
    iouLabel.text = String(format: "%.2f", iouSlider.value)
  }
  
  @IBAction func confChanged() {
    confLabel.text = String(format: "%.2f", confSlider.value)
  }

}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                  forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
  
  
  
}
