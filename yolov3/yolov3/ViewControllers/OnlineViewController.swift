//
//  OnlineViewController.swift
//  yolov3
//
//  Created by Alexander on 11/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import AVFoundation

class OnlineViewController: UIViewController {

  @IBOutlet weak var previewView: UIView!
  @IBOutlet weak var fpsLabel: UILabel!
  @IBOutlet weak var secPerFrameLabel: UILabel!
  @IBOutlet weak var modelLabel: UILabel!
  
  let captureSession = AVCaptureSession()
  let videoOutput = AVCaptureVideoDataOutput()
  let queue = DispatchQueue(label: "yolov3.camera-queue")
  
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var modelProvider: ModelProvider!
  var predictionLayer: PredictionLayer!
  let smoother = Smoother()
  let semaphore = DispatchSemaphore(value: 1)
  
  var lastTimestamp = CMTime()
  let maxFPS = 30

  override func viewDidLoad() {
    super.viewDidLoad()
    
    modelProvider = ModelProvider.shared
    predictionLayer = PredictionLayer()
    predictionLayer.update(imageViewFrame: previewView.frame,
                           imageSize: CGSize(width: 720, height: 1280))
    queue.async {
      self.semaphore.wait()
      let success = self.setUpCamera()
      self.semaphore.signal()
      DispatchQueue.main.async { [unowned self] in
        if success {
          if let previewLayer = self.previewLayer {
            self.previewView.layer.addSublayer(previewLayer)
            self.predictionLayer.addToParentLayer(self.previewView.layer)
            self.resizePreviewLayer()
          }
        } else {
          print("fail")
        }
      }
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.stopVideo()
    semaphore.signal()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    smoother.frameHistory = []
    let modelType = modelProvider.model.type!.description()
    modelLabel.text = "Model: " + modelType
    modelProvider.delegate = self
    self.startVideo()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  func startVideo() {
    if !captureSession.isRunning {
      DispatchQueue.main.async {
        self.semaphore.wait()
        self.captureSession.startRunning()
      }
    }
  }
  
  func stopVideo() {
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
  }
  
  func resizePreviewLayer() {
    previewLayer?.frame = previewView.bounds
  }
  
  func setUpCamera() -> Bool {
    captureSession.beginConfiguration ()
    captureSession.sessionPreset = .hd1280x720
    guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
      print("Error: no video devices available")
      return false
    }
    guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
      print("Error: could not create AVCaptureDeviceInput")
      return false
    }
    if captureSession.canAddInput(videoInput) {
      captureSession.addInput(videoInput)
    }
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    previewLayer.connection?.videoOrientation = .portrait
    self.previewLayer = previewLayer
    let settings: [String : Any] = [
      kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
    ]
    videoOutput.videoSettings = settings
    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.setSampleBufferDelegate(self, queue: queue)
    if captureSession.canAddOutput(videoOutput) {
      captureSession.addOutput(videoOutput)
    }
    videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
    captureSession.commitConfiguration()
    return true
  }
  
  func showAlert(title: String, msg: String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

}

extension OnlineViewController: ModelProviderDelegate {

  func show(predictions: [YOLO.Prediction]?,
            stat: ModelProvider.Statistics, error: YOLOError?) {
    guard let predictions = predictions else {
      guard let error = error else {
        showAlert(title: "Error!", msg: "Unknow error")
        return
      }
      if let errorDescription = error.errorDescription {
        showAlert(title: "Error!", msg: errorDescription)
      } else {
        showAlert(title: "Error!", msg: "Unknow error")
      }
      return
    }
    predictionLayer.clear()
    if Settings.shared.isSmoothed {
      smoother.addToFrameHistory(predictions: predictions)
      predictionLayer.addBoundingBoxes(predictions: smoother.getSmoothedBBoxes())
    } else {
      predictionLayer.addBoundingBoxes(predictions: predictions)
    }
    predictionLayer.show()
    self.fpsLabel.text = "FPS: " + String(format: "%.2f", stat.fps)
    self.secPerFrameLabel.text = "SecPerFrame: " + String(format: "%.2f", stat.timeForFrame)
  }
  
}

extension OnlineViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  public func captureOutput(_ output: AVCaptureOutput,
                            didOutput sampleBuffer: CMSampleBuffer,
                            from connection: AVCaptureConnection) {
    let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    let deltaTime = timestamp - lastTimestamp
    if deltaTime >= CMTimeMake(value: 1, timescale: Int32(maxFPS)) {
      if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
        if let frame = UIImage(pixelBuffer: imageBuffer) {
          modelProvider.predict(frame: frame)
        }
      }
    }
  }

}
