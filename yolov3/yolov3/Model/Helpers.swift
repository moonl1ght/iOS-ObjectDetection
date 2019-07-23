//
//  Helpers.swift
//  yolov3
//
//  Created by Alexander on 10/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import Foundation
import UIKit

let labels = ["person","bike","car","motorbike","aeroplane","bus",
              "train","truck","boat","traffic light","fire hydrant",
              "stop sign","parking meter","bench","bird","cat","dog",
              "horse","sheep","cow","elephant","bear","zebra","giraffe",
              "backpack","umbrella","handbag","tie","suitcase","frisbee",
              "skis","snowboard","sports ball","kite","baseball bat",
              "baseball glove","skateboard","surfboard","tennis racket",
              "bottle","wine glass","cup","fork","knife","spoon","bowl",
              "banana","apple","sandwich","orange","broccoli","carrot",
              "hot dog","pizza","donut","cake","chair","sofa","pottedplant",
              "bed","diningtable","toilet","tvmonitor","laptop","mouse",
              "remote","keyboard","cell phone","microwave","oven","toaster",
              "sink","refrigerator","book","clock","vase","scissors",
              "teddy bear","hair drier","toothbrush"]

struct ColorPallete {
  static let shared = ColorPallete()
  let colors: [CGColor]
  init() {
    colors = [
      ColorPallete.rgba(244,67,54,1), ColorPallete.rgba(33,150,243,1),
      ColorPallete.rgba(156,39,176,1), ColorPallete.rgba(0,150,136,1),
      ColorPallete.rgba(76,175,80,1), ColorPallete.rgba(139,195,74,1),
      ColorPallete.rgba(205,220,57,1), ColorPallete.rgba(255,235,59,1),
      ColorPallete.rgba(255,193,7,1), ColorPallete.rgba(255,152,0,1),
      ColorPallete.rgba(255,87,34,1), ColorPallete.rgba(121,85,72,1),
      ColorPallete.rgba(96,125,139,1), ColorPallete.rgba(183,28,28 ,1),
      ColorPallete.rgba(136,14,79 ,1), ColorPallete.rgba(74,20,140 ,1),
      ColorPallete.rgba(49,27,146 ,1), ColorPallete.rgba(26,35,126 ,1),
      ColorPallete.rgba(13,71,161 ,1), ColorPallete.rgba(1,87,155 ,1),
      ColorPallete.rgba(0,96,100 ,1), ColorPallete.rgba(0,77,64 ,1),
      ColorPallete.rgba(27,94,32 ,1), ColorPallete.rgba(51,105,30 ,1),
      ColorPallete.rgba(130,119,23 ,1), ColorPallete.rgba(245,127,23 ,1),
      ColorPallete.rgba(255,111,0 ,1), ColorPallete.rgba(230,81,0 ,1),
      ColorPallete.rgba(191,54,12 ,1), ColorPallete.rgba(255,82,82 ,1),
      ColorPallete.rgba(255,64,129 ,1), ColorPallete.rgba(224,64,251 ,1),
      ColorPallete.rgba(124,77,255 ,1), ColorPallete.rgba(83,109,254 ,1),
      ColorPallete.rgba(68,138,255 ,1), ColorPallete.rgba(64,196,255 ,1),
      ColorPallete.rgba(24,255,255 ,1), ColorPallete.rgba(100,255,218 ,1),
      ColorPallete.rgba(105,240,174 ,1), ColorPallete.rgba(178,255,89 ,1),
      ColorPallete.rgba(238,255,65 ,1), ColorPallete.rgba(255,255,0 ,1),
      ColorPallete.rgba(255,215,64 ,1), ColorPallete.rgba(255,171,64 ,1),
      ColorPallete.rgba(255,110,64 ,1), ColorPallete.rgba(26,188,156 ,1),
      ColorPallete.rgba(46,204,113 ,1), ColorPallete.rgba(52,152,219 ,1),
      ColorPallete.rgba(155,89,182 ,1), ColorPallete.rgba(52,73,94 ,1),
      ColorPallete.rgba(44,62,80 ,1), ColorPallete.rgba(142,68,173 ,1),
      ColorPallete.rgba(41,128,185 ,1), ColorPallete.rgba(39,174,96 ,1),
      ColorPallete.rgba(22,160,133 ,1), ColorPallete.rgba(241,196,15 ,1),
      ColorPallete.rgba(230,126,34 ,1), ColorPallete.rgba(231,76,60 ,1),
      ColorPallete.rgba(243,156,18 ,1), ColorPallete.rgba(255,185,0 ,1),
      ColorPallete.rgba(231,72,86 ,1), ColorPallete.rgba(0,178,148 ,1),
      ColorPallete.rgba(132,117,69 ,1), ColorPallete.rgba(100,124,100 ,1),
      ColorPallete.rgba(135,100,184 ,1), ColorPallete.rgba(191,0,119 ,1),
      ColorPallete.rgba(81,92,107 ,1), ColorPallete.rgba(105,121,126 ,1),
      ColorPallete.rgba(202,80,16 ,1), ColorPallete.rgba(1,133,116 ,1),
      ColorPallete.rgba(0,204,106 ,1), ColorPallete.rgba(194,57,179 ,1),
      ColorPallete.rgba(0,153,188 ,1), ColorPallete.rgba(142,140,216 ,1),
      ColorPallete.rgba(107,105,214 ,1), ColorPallete.rgba(116,77,169 ,1),
      ColorPallete.rgba(195,0,82 ,1), ColorPallete.rgba(118,118,118 ,1),
      ColorPallete.rgba(195,100,82 ,1), ColorPallete.rgba(32,118,108 ,1)
    ]
  }
  
  private static func rgba(_ red: CGFloat, _ green: CGFloat,
                           _ blue: CGFloat, _ alpha: CGFloat) -> CGColor {
    return UIColor(red: red / 255.0, green: green / 255.0,
                   blue: blue / 255.0, alpha: alpha).cgColor
  }
}

let anchors1_tiny: [Float] = [81,82 , 135,169,  344,319]
let anchors2_tiny: [Float] = [10,14,  23,27,  37,58]

let tiny_anchors = [
  "output1": anchors1_tiny,
  "output2": anchors2_tiny
]

let anchors1: [Float] = [116,90,  156,198,  373,326]
let anchors2: [Float] = [30,61,  62,45,  59,119]
let anchors3: [Float] = [10,13,  16,30,  33,23]

let anchors_416 = [
  "output1": anchors1,
  "output2": anchors2,
  "output3": anchors3
]
