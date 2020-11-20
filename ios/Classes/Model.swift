//
//  Model.swift
//  flutter_customvision
//
//  Created by macuser on 2020/10/26.
//

import Foundation
import Flutter
import Vision
import CVSInference

enum CustomvisionError: Error {
  case RequiredLoadConig
  //  case InvalidSection // 不正な選択
  //  case InsufficientFunds(required: Int) // 金額不足
  //  case OutOfStock // 在庫切れ
}

protocol CustomvisionProtocol: class {
  func load(manifest: String)
  func isLoaded() -> Bool
  func run(_ typedData: FlutterStandardTypedData, width: Int, height: Int, bytesPerRow: [Int], threshold: Double, maxReturns: Int) throws -> NSMutableDictionary
}

class CustomvisionBase {
  let _registrar: FlutterPluginRegistrar
  required init(registrar: FlutterPluginRegistrar) {
    self._registrar = registrar
    assert(type(of: self) != CustomvisionBase.self, "CustomvisionBaseはインスタンス化に対応していません")
    assert(self is CustomvisionProtocol, "CustomvisionProtocolを採用する必用があります")
  }

  func imageOrientationFromDeviceOrientation() -> UIImage.Orientation {
    let curDeviceOrientation = UIDevice.current.orientation
    let imageOrientation: UIImage.Orientation

    switch curDeviceOrientation {
    case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
      imageOrientation = .left
    case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
      imageOrientation = .up
    case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
      imageOrientation = .down
    case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
      imageOrientation = .right
    default:
      imageOrientation = .up
    }
    return imageOrientation
  }

  func unsafeMutableRawBufferPointerToUIImage(
    _ rawBufferPointer: UnsafeMutableRawBufferPointer,
    width: Int,
    height: Int,
    bytesPerRow: [Int]
  ) -> UIImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    let rawPtr = rawBufferPointer.baseAddress!

    let context = CGContext(
      data: rawPtr,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: bytesPerRow[0],
      space: colorSpace,
      bitmapInfo: bitmapInfo.rawValue)

    let quartzImage = context!.makeImage()
    return UIImage(
      cgImage: quartzImage!,
      scale: 1.0,
      orientation: imageOrientationFromDeviceOrientation()
    )
  }
}

class CustomvisionObjectDetector: CustomvisionBase {
  var objectDetector: CVSObjectDetector!
  var supportedIdentifiers: [String]!
}

extension CustomvisionObjectDetector: CustomvisionProtocol {
  func isLoaded() -> Bool {
    return objectDetector != nil
  }

  func load(manifest: String) {
    let config = CVSObjectDetectorConfig()
    let key = _registrar.lookupKey(forAsset: manifest)
    if let resourceString = Bundle.main.path(forResource: key, ofType: nil) {
      config.modelFile.string = resourceString
      config.build()
      supportedIdentifiers = config.supportedIdentifiers.values

      // create ObjectDetector
      objectDetector = CVSObjectDetector(config: config)
    }
  }

  func run(_ typedData: FlutterStandardTypedData, width: Int, height: Int, bytesPerRow: [Int], threshold: Double, maxReturns: Int) throws -> NSMutableDictionary {
    if isLoaded() == false {
      throw CustomvisionError.RequiredLoadConig
    }

    let imagePrediction = NSMutableDictionary()

    var data: Data = typedData.data
    data.withUnsafeMutableBytes { rawBufferPointer in
      // ObjectDetector input
      objectDetector?.threshold.value = Float(threshold)
      objectDetector?.maxReturns.value = Int32(maxReturns)
      objectDetector?.image.image = unsafeMutableRawBufferPointerToUIImage(rawBufferPointer, width: width, height: height, bytesPerRow: bytesPerRow)

      // run ObjectDetector
      objectDetector?.run()

      var predictions: [NSMutableDictionary] = []
      // ObjectDetector outputs
      let identifiers = self.objectDetector.identifiers
      let identifierIndex = self.objectDetector.identifierIndexes
      let confidences = self.objectDetector.confidences
      let boundingBoxes = self.objectDetector.boundingBoxes

      let countOfIdentifiers = identifiers?.countOfString() ?? 0
      for index in 0..<countOfIdentifiers {
        guard let identifier = identifiers?.string(at: index) else {
          continue
        }
        guard let identifierIndex = identifierIndex?.value(at: index) else {
          continue
        }
        guard let confidence = confidences?.value(at: index) else {
          continue
        }
        guard let rect = boundingBoxes?.rect(at: index) else {
          continue
        }

        let boundingBox = NSMutableDictionary()
        boundingBox["left"] = rect.minX
        boundingBox["top"] = rect.minY
        boundingBox["width"] = rect.maxX - rect.minX
        boundingBox["height"] = rect.maxY - rect.minY

        let model = NSMutableDictionary()
        model["probability"] = confidence
        model["tagName"] = identifier
        model["tagId"] = String(identifierIndex)
        model["boundingBox"] = boundingBox
        predictions.append(model)
      }

      imagePrediction["id"] = ""
      imagePrediction["project"] = ""
      imagePrediction["iteration"] = ""
      imagePrediction["created"] = ""
      imagePrediction["predictions"] = predictions
    }
    return imagePrediction
  }
}

class CustomvisionClassifier: CustomvisionBase {
  var skill: CVSClassifier!
}

extension CustomvisionClassifier: CustomvisionProtocol {
  func load(manifest: String) {
    // create skill configuration
    let config = CVSClassifierConfig()
    let key = _registrar.lookupKey(forAsset: manifest)
    config.modelFile.string = Bundle.main.path(forResource: key, ofType: nil)
    config.build()

    // create skill instance
    skill = CVSClassifier(config: config);
  }

  func isLoaded() -> Bool {
    return skill != nil
  }

  func run(_ typedData: FlutterStandardTypedData, width: Int, height: Int, bytesPerRow: [Int], threshold: Double, maxReturns: Int) throws -> NSMutableDictionary {
    if isLoaded() == false {
      throw CustomvisionError.RequiredLoadConig
    }

    let imagePrediction = NSMutableDictionary()

    var data: Data = typedData.data

    data.withUnsafeMutableBytes { rawBufferPointer in
      // ObjectDetector input
      skill?.threshold.value = Float(threshold)
      skill?.maxReturns.value = Int32(maxReturns)
      skill?.image.image = unsafeMutableRawBufferPointerToUIImage(rawBufferPointer, width: width, height: height, bytesPerRow: bytesPerRow)

      // run and report results
      skill?.run()

      var predictions: [NSMutableDictionary] = []

      let identifiers = self.skill.identifiers
      let confidences = self.skill.confidences

      let countOfIdentifiers = identifiers?.countOfString() ?? 0
      for index in 0..<countOfIdentifiers {
        guard let confidence = confidences?.value(at: index) else {
          continue
        }
        guard let identifier = identifiers?.string(at: index) else {
          continue
        }

        let boundingBox = NSMutableDictionary()
        boundingBox["left"] = 0.0
        boundingBox["top"] = 0.0
        boundingBox["width"] = 0.0
        boundingBox["height"] = 0.0

        let model = NSMutableDictionary()
        model["probability"] = confidence
        model["tagName"] = identifier
        model["tagId"] = identifier
        model["boundingBox"] = boundingBox
        predictions.append(model)
      }

      imagePrediction["id"] = ""
      imagePrediction["project"] = ""
      imagePrediction["iteration"] = ""
      imagePrediction["created"] = ""
      imagePrediction["predictions"] = predictions
    }
    return imagePrediction
  }
}
