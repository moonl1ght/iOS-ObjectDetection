//
//  YOLO.swift
//  yolov3
//
//  Created by Alexander on 02/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import CoreML
import UIKit
import Accelerate

enum YOLOType {
  case v3_Tiny
  case v3_416
  
  func description() -> String {
    switch self {
    case .v3_416:
      return "YOLOv3-416"
    case .v3_Tiny:
      return "YOLOv3-tiny"
    }
  }
  
  static func initFrom(name: String) -> YOLOType {
    switch name {
    case "YOLOv3-tiny":
      return .v3_Tiny
    case "YOLOv3-416":
      return .v3_416
    default:
      return .v3_Tiny
    }
  }
  
  static func modelNames() -> [String] {
    return ["YOLOv3-tiny", "YOLOv3-416"]
  }
}

class YOLO: NSObject {
  
  static let inputSize: Float = 416.0
  static let boxesPerCell: Int = 3
  
  private var model: MLModel?
  private let pixelBufferSize = CGSize(width: CGFloat(YOLO.inputSize),
                                       height: CGFloat(YOLO.inputSize))
  private let inputName = "image"
  private var classes = [Float](repeating: 0, count: 80)
  private var anchors: [String: Array<Float>]!
  
  var confidenceThreshold: Float
  var iouThreshold: Float
  
  var type: YOLOType!
  
  struct Prediction {
    let classIndex: Int
    let score: Float
    let rect: CGRect
  }

  override init() {
    confidenceThreshold = Settings.shared.confidenceThreshold
    iouThreshold = Settings.shared.iouThreshold
    super.init()
  }
  
  convenience init(type: YOLOType) throws {
    self.init()
    var url: URL? = nil
    self.type = type
    switch type {
    case .v3_Tiny:
      url = Bundle.main.url(forResource: "yolo-tiny", withExtension:"mlmodelc")
      self.anchors = tiny_anchors
    case .v3_416:
      url = Bundle.main.url(forResource: "yolo", withExtension:"mlmodelc")
      self.anchors = anchors_416
    }
    guard let modelURL = url else {
      throw YOLOError.modelFileNotFound
    }
    do {
      model = try MLModel(contentsOf: modelURL)
    } catch let error {
      print(error)
      throw YOLOError.modelCreationError
    }
  }
  
  func predict(frame: UIImage) throws -> [Prediction] {
    guard let cvBufferInput = frame.pixelBuffer(width: Int(YOLO.inputSize),
                                                height: Int(YOLO.inputSize)) else {
      throw YOLOError.pixelBufferError
    }
    let input = YOLOInput(inputImage: cvBufferInput,
                          inputName: inputName)
    guard let model = self.model else {
      throw YOLOError.noModel
    }
    let output = try model.prediction(from: input)
    var predictions = [Prediction]()
    for name in output.featureNames {
      let res = try process(output: output.featureValue(for: name)!.multiArrayValue!,
                            name: name)
      predictions.append(contentsOf: res)
    }
    nonMaxSuppression(boxes: &predictions, threshold: iouThreshold)
    return predictions
  }
  
  private func process(output out: MLMultiArray, name: String) throws -> [Prediction] {
    var predictions = [Prediction]()
    let grid = out.shape[out.shape.count-1].intValue
    let gridSize = YOLO.inputSize / Float(grid)
    let classesCount = labels.count
    let pointer = UnsafeMutablePointer<Double>(OpaquePointer(out.dataPointer))
    if out.strides.count < 3 {
      throw YOLOError.strideOutOfBounds
    }
    let channelStride = out.strides[out.strides.count-3].intValue
    let yStride = out.strides[out.strides.count-2].intValue
    let xStride = out.strides[out.strides.count-1].intValue
    func offset(ch: Int, x: Int, y: Int) -> Int {
      return ch * channelStride + y * yStride + x * xStride
    }
    for x in 0 ..< grid {
      for y in 0 ..< grid {
        for box_i in 0 ..< YOLO.boxesPerCell {
          let boxOffset = box_i * (classesCount + 5)
          let bbx = Float(pointer[offset(ch: boxOffset, x: x, y: y)])
          let bby = Float(pointer[offset(ch: boxOffset + 1, x: x, y: y)])
          let bbw = Float(pointer[offset(ch: boxOffset + 2, x: x, y: y)])
          let bbh = Float(pointer[offset(ch: boxOffset + 3, x: x, y: y)])
          let confidence = sigmoid(Float(pointer[offset(ch: boxOffset + 4, x: x, y: y)]))
          if confidence < confidenceThreshold {
            continue
          }
          let x_pos = (sigmoid(bbx) + Float(x)) * gridSize
          let y_pos = (sigmoid(bby) + Float(y)) * gridSize
          let width = exp(bbw) * self.anchors[name]![2 * box_i]
          let height = exp(bbh) * self.anchors[name]![2 * box_i + 1]
          for c in 0 ..< 80 {
            classes[c] = Float(pointer[offset(ch: boxOffset + 5 + c, x: x, y: y)])
          }
          softmax(&classes)
          let (detectedClass, bestClassScore) = argmax(classes)
          let confidenceInClass = bestClassScore * confidence
          if confidenceInClass < confidenceThreshold {
            continue
          }
          predictions.append(Prediction(classIndex: detectedClass,
                                  score: confidenceInClass,
                                  rect: CGRect(x: CGFloat(x_pos - width / 2),
                                               y: CGFloat(y_pos - height / 2),
                                               width: CGFloat(width),
                                               height: CGFloat(height))))
        }
      }
    }
    return predictions
  }

}

// MARK: - YOLO Helpers

extension YOLO {
  
  private func nonMaxSuppression(boxes: inout [Prediction], threshold: Float) {
    var i = 0
    while i < boxes.count {
      var j = i + 1
      while j < boxes.count {
        let iou = YOLO.IOU(a: boxes[i].rect, b: boxes[j].rect)
        if iou > threshold {
          if boxes[i].score > boxes[j].score {
            if boxes[i].classIndex == boxes[j].classIndex {
              boxes.remove(at: j)
            } else {
              j += 1
            }
          } else {
            if boxes[i].classIndex == boxes[j].classIndex {
              boxes.remove(at: i)
              j = i + 1
            } else {
              j += 1
            }
          }
        } else {
          j += 1
        }
      }
      i += 1
    }
  }
  
  static func IOU(a: CGRect, b: CGRect) -> Float {
    let areaA = a.width * a.height
    if areaA <= 0 { return 0 }
    let areaB = b.width * b.height
    if areaB <= 0 { return 0 }
    let intersection = a.intersection(b)
    let intersectionArea = intersection.width * intersection.height
    return Float(intersectionArea / (areaA + areaB - intersectionArea))
  }
  
  private func argmax(_ x: [Float]) -> (Int, Float) {
    let len = vDSP_Length(x.count)
    var i: vDSP_Length = 0
    var max: Float = 0
    vDSP_maxmgvi(x, 1, &max, &i,len)
    return (Int(i), max)
  }
  
  private func sigmoid(_ x: Float) -> Float {
    return 1 / (1 + exp(-x))
  }
  
  private func softmax(_ x: inout [Float]) {
    let len = vDSP_Length(x.count)
    var count = Int32(x.count)
    vvexpf(&x, x, &count)
    var sum: Float = 0
    vDSP_sve(x, 1, &sum, len)
    vDSP_vsdiv(x, 1, &sum, &x, 1, len)
  }
  
}

// MARK: - YOLOInput

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
private class YOLOInput : MLFeatureProvider {
  
  var inputImage: CVPixelBuffer
  var inputName: String
  var featureNames: Set<String> {
    get { return [inputName] }
  }
  
  func featureValue(for featureName: String) -> MLFeatureValue? {
    if (featureName == inputName) {
      return MLFeatureValue(pixelBuffer: inputImage)
    }
    return nil
  }
  
  init(inputImage: CVPixelBuffer, inputName: String) {
    self.inputName = inputName
    self.inputImage = inputImage
  }
}
