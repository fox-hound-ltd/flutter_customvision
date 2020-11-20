import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_customvision/flutter_customvision.dart';

void main() {
  const String tfliteManifest = 'assets/tflite/cvexport.manifest';
  const String coreMLManifest = 'assets/coreML/cvexport.manifest';
  const MethodChannel channel = MethodChannel('flutter_customvision');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'loadObjectDetection' ||
          methodCall.method == 'loadClassification') {
        if (methodCall.arguments['coreML'] != null &&
            methodCall.arguments['tflite'] != null &&
            methodCall.arguments['coreML'].toString() == coreMLManifest &&
            methodCall.arguments['tflite'] == tfliteManifest) {
          return true;
        } else {
          return false;
        }
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('load no args', () async {
    expect(await FlutterCustomvision.loadObjectDetection(), false);
    expect(await FlutterCustomvision.loadClassification(), false);
  });

  test('load no such file', () async {
    expect(
        await FlutterCustomvision.loadObjectDetection(
            coreML: 'nofile', tflite: 'nofile'),
        false);
    expect(
        await FlutterCustomvision.loadClassification(
            coreML: 'nofile', tflite: 'nofile'),
        false);
  });

  test('load', () async {
    expect(
        await FlutterCustomvision.loadObjectDetection(
            coreML: coreMLManifest, tflite: tfliteManifest),
        true);
    expect(
        await FlutterCustomvision.loadClassification(
            coreML: coreMLManifest, tflite: tfliteManifest),
        true);
  });
}
