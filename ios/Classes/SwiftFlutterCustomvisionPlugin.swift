import Flutter
import UIKit
import Vision
import CVSInference

public class SwiftFlutterCustomvisionPlugin: NSObject, FlutterPlugin {
  let _registrar: FlutterPluginRegistrar
  // ObjectDetector
  var objectDetector: CustomvisionObjectDetector!
  // Classifier
  var skill: CustomvisionClassifier!

  init(_ resistrar: FlutterPluginRegistrar) {
    self._registrar = resistrar
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_customvision", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterCustomvisionPlugin(registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "loadObjectDetection" {
      loadObjectDetection(call, result)
    } else if call.method == "detectObjectOnFrame" {
      detectObjectOnFrame(call, result)
    } else if call.method == "loadClassification" {
      loadClassification(call, result)
    } else if call.method == "classifyOnFrame" {
      classifyOnFrame(call, result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}

// MARK: ObjectDetector
extension SwiftFlutterCustomvisionPlugin {
  func loadObjectDetection(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
       let manifest = args["coreML"] as? String {

      objectDetector = CustomvisionObjectDetector.init(registrar: _registrar)
      objectDetector.load(manifest: manifest)

      if objectDetector.isLoaded() {
        result(true)
      } else {
        result(FlutterError.init(code: "Load Error", message: nil, details: nil))
      }
    } else {
      result(FlutterError.init(code: "Bad args", message: nil, details: nil))
    }
  }

  func detectObjectOnFrame(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if objectDetector == nil || !objectDetector.isLoaded() {
      result(FlutterError.init(code: "Error", message: "Required loadObjectDetection", details: nil))
      return
    }
    if let args = call.arguments as? Dictionary<String, Any>,
       let listTypedData = args["bytesList"] as? NSArray,
       let typedData = listTypedData[0] as? FlutterStandardTypedData,
       let height = args["height"] as? Int,
       let width = args["width"] as? Int,
       let bytesPerRow = args["bytesPerRow"] as? [Int],
       let threshold = args["threshold"] as? Double,
       let maxReturns = args["maxReturns"] as? Int {

      do {
        let imagePrediction = try objectDetector.run(typedData, width: width, height: height, bytesPerRow: bytesPerRow, threshold: threshold, maxReturns: maxReturns)
        result(imagePrediction)
      } catch CustomvisionError.RequiredLoadConig {
        result(FlutterError.init(code: "Error", message: "Required loadObjectDetection", details: nil))
      } catch {
        result(FlutterError.init(code: "Bad args", message: nil, details: nil))
      }
    } else {
      result(FlutterError.init(code: "Bad args", message: nil, details: nil))
    }
  }
}

// MARK: Classifier
extension SwiftFlutterCustomvisionPlugin {
  func loadClassification(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if let args = call.arguments as? Dictionary<String, Any>,
       let manifest = args["coreML"] as? String {

      skill = CustomvisionClassifier.init(registrar: _registrar)
      skill.load(manifest: manifest)

      if skill.isLoaded() {
        result(true)
      } else {
        result(FlutterError.init(code: "Load Error", message: nil, details: nil))
      }
    } else {
      result(FlutterError.init(code: "Bad args", message: nil, details: nil))
    }
  }

  func classifyOnFrame(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    if skill == nil || !skill.isLoaded() {
      result(FlutterError.init(code: "Error", message: "Required loadClassification", details: nil))
      return
    }
    if let args = call.arguments as? Dictionary<String, Any>,
       let listTypedData = args["bytesList"] as? NSArray,
       let typedData = listTypedData[0] as? FlutterStandardTypedData,
       let height = args["height"] as? Int,
       let width = args["width"] as? Int,
       let bytesPerRow = args["bytesPerRow"] as? [Int],
       let threshold = args["threshold"] as? Double,
       let maxReturns = args["maxReturns"] as? Int {

      do {
        let imagePrediction = try skill.run(typedData, width: width, height: height, bytesPerRow: bytesPerRow, threshold: threshold, maxReturns: maxReturns)
        result(imagePrediction)
      } catch CustomvisionError.RequiredLoadConig {
        result(FlutterError.init(code: "Error", message: "Required loadObjectDetection", details: nil))
      } catch {
        result(FlutterError.init(code: "Bad args", message: nil, details: nil))
      }
    } else {
      result(FlutterError.init(code: "Bad args", message: nil, details: nil))
    }
  }
}
