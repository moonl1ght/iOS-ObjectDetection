//
//  Smoother.swift
//  yolov3
//
//  Created by Alexander on 23/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import Foundation
import UIKit

class Smoother {
  
  let maxFrameHistory = 30
  
  var frameHistory: [[YOLO.Prediction]]
  
  init () {
    frameHistory = []
  }
  
  func addToFrameHistory(predictions: [YOLO.Prediction]) {
    if frameHistory.count > maxFrameHistory {
      frameHistory.removeFirst()
    }
    frameHistory.append(predictions)
  }
  
  func getSmoothedBBoxes() -> [YOLO.Prediction] {
    guard let lastFrame = frameHistory.last else {
      return []
    }
    var smoothedBBoxes: [YOLO.Prediction] = []
    for lastPred in lastFrame {
      var smoothedRect = lastPred.rect
      var count: CGFloat = 1
      for i in 0 ..< frameHistory.count - 1 {
        let frame = frameHistory[i]
        for pred in frame {
          let iou = YOLO.IOU(a: pred.rect, b: lastPred.rect)
          if iou > Settings.shared.iouThreshold && pred.classIndex == lastPred.classIndex {
            smoothedRect = CGRect(x: pred.rect.origin.x + smoothedRect.origin.x,
                                  y: pred.rect.origin.y + smoothedRect.origin.y,
                                  width: pred.rect.width + smoothedRect.width,
                                  height: pred.rect.height + smoothedRect.height)
            count += 1.0
          }
        }
      }
      smoothedBBoxes.append(YOLO.Prediction(classIndex: lastPred.classIndex,
                                            score: lastPred.score,
                                            rect: CGRect(x: smoothedRect.origin.x / count,
                                                         y: smoothedRect.origin.y / count,
                                                         width: smoothedRect.width / count,
                                                         height: smoothedRect.height / count)))
    }
    return smoothedBBoxes
  }

}
