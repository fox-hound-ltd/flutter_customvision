import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

part 'models.dart';

class FlutterCustomvision {
  static const MethodChannel _channel =
      const MethodChannel('flutter_customvision');

  /// Load customvision manifest
  static Future<bool> loadObjectDetection(
      {String coreML = '', String tflite = ''}) async {
    if (coreML.isEmpty && tflite.isEmpty) {
      return false;
    }
    return await _channel.invokeMethod(
        "loadObjectDetection", {"coreML": coreML, "tflite": tflite});
  }

  /// Run
  static Future<ImagePrediction> detectObjectOnFrame(
      List<Uint8List> bytesList, int height, int width, List<int> bytesPerRow,
      {double threshold = 0.4, int maxReturns = 10}) async {
    final dynamic result = await _channel.invokeMethod("detectObjectOnFrame", {
      "bytesList": bytesList,
      "height": height,
      "width": width,
      "bytesPerRow": bytesPerRow,
      "threshold": threshold,
      "maxReturns": maxReturns,
    });
    return ImagePrediction._fromPlatformData(result);
  }

  /// Load customvision manifest
  static Future<bool> loadClassification(
      {String coreML = '', String tflite = ''}) async {
    if (coreML.isEmpty && tflite.isEmpty) {
      return false;
    }
    return await _channel.invokeMethod(
        "loadClassification", {"coreML": coreML, "tflite": tflite});
  }

  /// Run
  static Future<ImagePrediction> classifyOnFrame(
      List<Uint8List> bytesList, int height, int width, List<int> bytesPerRow,
      {double threshold = 0.0, int maxReturns = 1}) async {
    final dynamic result = await _channel.invokeMethod("classifyOnFrame", {
      "bytesList": bytesList,
      "height": height,
      "width": width,
      "bytesPerRow": bytesPerRow,
      "threshold": threshold,
      "maxReturns": maxReturns,
    });
    return ImagePrediction._fromPlatformData(result);
  }
}
