part of 'flutter_customvision.dart';

/// BoundingBox bounding box that defines a region of an image.
class BoundingBox {
  BoundingBox._fromPlatformData(Map<dynamic, dynamic> data)
      : left = data['left'],
        top = data['top'],
        width = data['width'],
        height = data['height'];

  /// Left - Coordinate of the left boundary.
  final double left;

  /// Top - Coordinate of the top boundary.
  final double top;

  /// Width - Width.
  final double width;

  /// Height - Height.
  final double height;
}

/// ImagePrediction result of an image prediction request.
class ImagePrediction {
  ImagePrediction._fromPlatformData(Map<dynamic, dynamic> data)
      : id = data['id'],
        project = data['project'],
        iteration = data['iteration'],
        created = data['created'],
        predictions = List<Model>.unmodifiable(data['predictions']
            .map((dynamic prediction) => Model._fromPlatformData(prediction)));

  /// ID - READ-ONLY; Prediction Id.
  final String id;

  /// Project - READ-ONLY; Project Id.
  final String project;

  /// Iteration - READ-ONLY; Iteration Id.
  final String iteration;

  /// Created - READ-ONLY; Date this prediction was created.
  final String created;
  // Predictions - READ-ONLY; List of predictions.
  final List<Model> predictions;
}

/// Model prediction result.
class Model {
  Model._fromPlatformData(Map<dynamic, dynamic> data)
      : probability = data['probability'],
        tagId = data['tagId'],
        tagName = data['tagName'],
        boundingBox = BoundingBox._fromPlatformData(data['boundingBox']);

  /// Probability - READ-ONLY; Probability of the tag.
  final double probability;

  /// TagID - READ-ONLY; Id of the predicted tag.
  final String tagId;

  /// TagName - READ-ONLY; Name of the predicted tag.
  final String tagName;

  /// BoundingBox - READ-ONLY; Bounding box of the prediction.
  final BoundingBox boundingBox;
}
