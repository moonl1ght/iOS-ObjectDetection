//
//  ModelProvider.swift
//  yolov3
//
//  Created by Alexander on 02/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import CoreML

protocol ModelProviderDelegate: class {
  func show(predictions: [YOLO.Prediction]?,
            stat: ModelProvider.Statistics,
            error: YOLOError?)
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class ModelProvider {
  
  struct Statistics {
    var timeForFrame: Float
    var fps: Float
  }
  
  static let shared = ModelProvider(modelType: Settings.shared.modelType)
  
  var model: YOLO!
  weak var delegate: ModelProviderDelegate?
  
  var predicted = 0
  var timeOfFirstFrameInSecond = CACurrentMediaTime()
  
  init(modelType type: YOLOType) {
    loadModel(type: type)
  }
  
  func reloadModel(type: YOLOType) {
    loadModel(type: type)
  }
  
  private func loadModel(type: YOLOType) {
    do {
      self.model = try YOLO(type: type)
    } catch {
      assertionFailure("error creating model")
    }
  }
  
  func predict(frame: UIImage) {
    DispatchQueue.global().async {
      do {
        let startTime = CACurrentMediaTime()
        let predictions = try self.model.predict(frame: frame)
        let elapsed = CACurrentMediaTime() - startTime
        self.showResultOnMain(predictions: predictions, elapsed: Float(elapsed), error: nil)
      } catch let error as YOLOError {
        self.showResultOnMain(predictions: nil, elapsed: -1, error: error)
      } catch {
        self.showResultOnMain(predictions: nil, elapsed: -1, error: YOLOError.unknownError)
      }
    }
  }
  
  private func showResultOnMain(predictions: [YOLO.Prediction]?,
                                elapsed: Float, error: YOLOError?) {
    if let delegate = self.delegate {
      DispatchQueue.main.async {
        let fps = self.measureFPS()
        delegate.show(predictions: predictions,
                      stat: ModelProvider.Statistics(timeForFrame: elapsed,
                                                     fps: fps),
                      error: error)
      }
    }
  }
  
  private func measureFPS() -> Float {
    predicted += 1
    let elapsed = CACurrentMediaTime() - timeOfFirstFrameInSecond
    let currentFPSDelivered = Double(predicted) / elapsed
    if elapsed > 1 {
      predicted = 0
      timeOfFirstFrameInSecond = CACurrentMediaTime()
    }
    return Float(currentFPSDelivered)
  }
  
}


