//
//  UIImageExt.swift
//  yolov3
//
//  Created by Alexander on 02/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import VideoToolbox

extension UIImage {
  
  /**
   Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
   */
  public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    return pixelBuffer(width: width, height: height,
                       pixelFormatType: kCVPixelFormatType_32ARGB,
                       colorSpace: CGColorSpaceCreateDeviceRGB(),
                       alphaInfo: .noneSkipFirst)
  }
  
  private func pixelBuffer(width: Int,
                           height: Int,
                           pixelFormatType: OSType,
                           colorSpace: CGColorSpace,
                           alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
    var maybePixelBuffer: CVPixelBuffer?
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     width,
                                     height,
                                     pixelFormatType,
                                     attrs as CFDictionary,
                                     &maybePixelBuffer)
    
    guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
      return nil
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
    guard let context = CGContext(data: pixelData,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                  space: colorSpace,
                                  bitmapInfo: alphaInfo.rawValue)
      else {
        return nil
    }
    UIGraphicsPushContext(context)
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    return pixelBuffer
  }
  
  /**
   Creates a new UIImage from a CVPixelBuffer.
   NOTE: This only works for RGB pixel buffers, not for grayscale.
   */
  public convenience init?(pixelBuffer: CVPixelBuffer) {
    var cgImage: CGImage?
    VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
    if let cgImage = cgImage {
      self.init(cgImage: cgImage)
    } else {
      return nil
    }
  }
}
