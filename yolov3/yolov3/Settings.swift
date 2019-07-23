//
//  Settings.swift
//  yolov3
//
//  Created by Alexander on 19/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import Foundation

private let defaultModel = YOLOType.v3_Tiny
private let defaultIOUThreshold: Float = 0.3
private let defaultConfidenceThreshold: Float = 0.2


class Settings {
  
  static let shared = Settings()
  
  var confidenceThreshold: Float
  var iouThreshold: Float
  var modelType: YOLOType
  
  private weak var modelProvider: ModelProvider?
  
  init() {
    confidenceThreshold = defaultConfidenceThreshold
    iouThreshold = defaultIOUThreshold
    modelType = defaultModel
  }
  
  func save() {
    
  }
  
  func restore() {
    confidenceThreshold = defaultConfidenceThreshold
    iouThreshold = defaultIOUThreshold
    modelType = defaultModel
  }
  
}
