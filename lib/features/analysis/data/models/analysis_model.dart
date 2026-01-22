class AnalysisModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String result;
  final DateTime createdAt;

  AnalysisModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.result,
    required this.createdAt,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      id: json['id'],
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      result: json['result'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'result': result,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}