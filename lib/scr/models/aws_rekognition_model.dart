class AwsRekognitionModel {
  List<FaceMatches> faceMatches;
  SourceImageFace sourceImageFace;
  List<Face> unmatchedFaces;

  AwsRekognitionModel(
      {this.faceMatches, this.sourceImageFace, this.unmatchedFaces});

  AwsRekognitionModel.fromJson(Map<String, dynamic> json) {
    if (json['FaceMatches'] != null) {
      faceMatches = new List<FaceMatches>();
      json['FaceMatches'].forEach((v) {
        faceMatches.add(new FaceMatches.fromJson(v));
      });
    }
    sourceImageFace = json['SourceImageFace'] != null
        ? new SourceImageFace.fromJson(json['SourceImageFace'])
        : null;
    if (json['UnmatchedFaces'] != null) {
      unmatchedFaces = new List<Face>();
      json['UnmatchedFaces'].forEach((v) {
        unmatchedFaces.add(new Face.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.faceMatches != null) {
      data['FaceMatches'] = this.faceMatches.map((v) => v.toJson()).toList();
    }
    if (this.sourceImageFace != null) {
      data['SourceImageFace'] = this.sourceImageFace.toJson();
    }
    if (this.unmatchedFaces != null) {
      data['UnmatchedFaces'] =
          this.unmatchedFaces.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FaceMatches {
  Face face;
  double similarity;

  FaceMatches({this.face, this.similarity});

  FaceMatches.fromJson(Map<String, dynamic> json) {
    face = json['Face'] != null ? new Face.fromJson(json['Face']) : null;
    similarity = json['Similarity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.face != null) {
      data['Face'] = this.face.toJson();
    }
    data['Similarity'] = this.similarity;
    return data;
  }
}

class Face {
  BoundingBox boundingBox;
  double confidence;
  List<Landmarks> landmarks;
  Pose pose;
  Quality quality;

  Face(
      {this.boundingBox,
      this.confidence,
      this.landmarks,
      this.pose,
      this.quality});

  Face.fromJson(Map<String, dynamic> json) {
    boundingBox = json['BoundingBox'] != null
        ? new BoundingBox.fromJson(json['BoundingBox'])
        : null;
    confidence = json['Confidence'];
    if (json['Landmarks'] != null) {
      landmarks = new List<Landmarks>();
      json['Landmarks'].forEach((v) {
        landmarks.add(new Landmarks.fromJson(v));
      });
    }
    pose = json['Pose'] != null ? new Pose.fromJson(json['Pose']) : null;
    quality =
        json['Quality'] != null ? new Quality.fromJson(json['Quality']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.boundingBox != null) {
      data['BoundingBox'] = this.boundingBox.toJson();
    }
    data['Confidence'] = this.confidence;
    if (this.landmarks != null) {
      data['Landmarks'] = this.landmarks.map((v) => v.toJson()).toList();
    }
    if (this.pose != null) {
      data['Pose'] = this.pose.toJson();
    }
    if (this.quality != null) {
      data['Quality'] = this.quality.toJson();
    }
    return data;
  }
}

class BoundingBox {
  double height;
  double left;
  double top;
  double width;

  BoundingBox({this.height, this.left, this.top, this.width});

  BoundingBox.fromJson(Map<String, dynamic> json) {
    height = json['Height'];
    left = json['Left'];
    top = json['Top'];
    width = json['Width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Height'] = this.height;
    data['Left'] = this.left;
    data['Top'] = this.top;
    data['Width'] = this.width;
    return data;
  }
}

class Landmarks {
  String type;
  double x;
  double y;

  Landmarks({this.type, this.x, this.y});

  Landmarks.fromJson(Map<String, dynamic> json) {
    type = json['Type'];
    x = json['X'];
    y = json['Y'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Type'] = this.type;
    data['X'] = this.x;
    data['Y'] = this.y;
    return data;
  }
}

class Pose {
  double pitch;
  double roll;
  double yaw;

  Pose({this.pitch, this.roll, this.yaw});

  Pose.fromJson(Map<String, dynamic> json) {
    pitch = json['Pitch'];
    roll = json['Roll'];
    yaw = json['Yaw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Pitch'] = this.pitch;
    data['Roll'] = this.roll;
    data['Yaw'] = this.yaw;
    return data;
  }
}

class Quality {
  double brightness;
  double sharpness;

  Quality({this.brightness, this.sharpness});

  Quality.fromJson(Map<String, dynamic> json) {
    brightness = json['Brightness'];
    sharpness = json['Sharpness'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Brightness'] = this.brightness;
    data['Sharpness'] = this.sharpness;
    return data;
  }
}

class SourceImageFace {
  BoundingBox boundingBox;
  double confidence;

  SourceImageFace({this.boundingBox, this.confidence});

  SourceImageFace.fromJson(Map<String, dynamic> json) {
    boundingBox = json['BoundingBox'] != null
        ? new BoundingBox.fromJson(json['BoundingBox'])
        : null;
    confidence = json['Confidence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.boundingBox != null) {
      data['BoundingBox'] = this.boundingBox.toJson();
    }
    data['Confidence'] = this.confidence;
    return data;
  }
}
