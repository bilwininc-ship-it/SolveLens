// Quota model for tracking user quota usage
class QuotaModel {
  final int textQuestionsUsed;
  final int textQuestionsLimit;
  final int voiceMinutesUsed;
  final int voiceMinutesLimit;
  final int imageScansUsed;
  final int imageScansLimit;
  final DateTime resetDate;

  const QuotaModel({
    required this.textQuestionsUsed,
    required this.textQuestionsLimit,
    required this.voiceMinutesUsed,
    required this.voiceMinutesLimit,
    required this.imageScansUsed,
    required this.imageScansLimit,
    required this.resetDate,
  });

  /// Creates a free tier quota model with default limits
  factory QuotaModel.freeTier() {
    return QuotaModel(
      textQuestionsUsed: 0,
      textQuestionsLimit: 10,
      voiceMinutesUsed: 0,
      voiceMinutesLimit: 5,
      imageScansUsed: 0,
      imageScansLimit: 10,
      resetDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  /// Check if user has text quota remaining
  bool get hasTextQuota => textQuestionsUsed < textQuestionsLimit;

  /// Check if user has voice quota remaining
  bool get hasVoiceQuota => voiceMinutesUsed < voiceMinutesLimit;

  /// Check if user has image quota remaining
  bool get hasImageQuota => imageScansUsed < imageScansLimit;

  /// Calculate percentage of text quota used
  double get textQuotaPercentage {
    if (textQuestionsLimit == 0) return 0;
    return (textQuestionsUsed / textQuestionsLimit).clamp(0.0, 1.0);
  }

  /// Calculate percentage of voice quota used
  double get voiceQuotaPercentage {
    if (voiceMinutesLimit == 0) return 0;
    return (voiceMinutesUsed / voiceMinutesLimit).clamp(0.0, 1.0);
  }

  /// Calculate percentage of image quota used
  double get imageQuotaPercentage {
    if (imageScansLimit == 0) return 0;
    return (imageScansUsed / imageScansLimit).clamp(0.0, 1.0);
  }

  /// Creates a copy with updated values
  QuotaModel copyWith({
    int? textQuestionsUsed,
    int? textQuestionsLimit,
    int? voiceMinutesUsed,
    int? voiceMinutesLimit,
    int? imageScansUsed,
    int? imageScansLimit,
    DateTime? resetDate,
  }) {
    return QuotaModel(
      textQuestionsUsed: textQuestionsUsed ?? this.textQuestionsUsed,
      textQuestionsLimit: textQuestionsLimit ?? this.textQuestionsLimit,
      voiceMinutesUsed: voiceMinutesUsed ?? this.voiceMinutesUsed,
      voiceMinutesLimit: voiceMinutesLimit ?? this.voiceMinutesLimit,
      imageScansUsed: imageScansUsed ?? this.imageScansUsed,
      imageScansLimit: imageScansLimit ?? this.imageScansLimit,
      resetDate: resetDate ?? this.resetDate,
    );
  }

  /// Converts QuotaModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'textQuestionsUsed': textQuestionsUsed,
      'textQuestionsLimit': textQuestionsLimit,
      'voiceMinutesUsed': voiceMinutesUsed,
      'voiceMinutesLimit': voiceMinutesLimit,
      'imageScansUsed': imageScansUsed,
      'imageScansLimit': imageScansLimit,
      'resetDate': resetDate.toIso8601String(),
    };
  }

  /// Creates a QuotaModel from JSON
  factory QuotaModel.fromJson(Map<String, dynamic> json) {
    return QuotaModel(
      textQuestionsUsed: json['textQuestionsUsed'] ?? 0,
      textQuestionsLimit: json['textQuestionsLimit'] ?? 10,
      voiceMinutesUsed: json['voiceMinutesUsed'] ?? 0,
      voiceMinutesLimit: json['voiceMinutesLimit'] ?? 5,
      imageScansUsed: json['imageScansUsed'] ?? 0,
      imageScansLimit: json['imageScansLimit'] ?? 10,
      resetDate: DateTime.parse(json['resetDate']),
    );
  }

  @override
  String toString() {
    return 'QuotaModel(text: $textQuestionsUsed/$textQuestionsLimit, '
        'voice: $voiceMinutesUsed/$voiceMinutesLimit, '
        'image: $imageScansUsed/$imageScansLimit, '
        'resetDate: $resetDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuotaModel &&
        other.textQuestionsUsed == textQuestionsUsed &&
        other.textQuestionsLimit == textQuestionsLimit &&
        other.voiceMinutesUsed == voiceMinutesUsed &&
        other.voiceMinutesLimit == voiceMinutesLimit &&
        other.imageScansUsed == imageScansUsed &&
        other.imageScansLimit == imageScansLimit &&
        other.resetDate == resetDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      textQuestionsUsed,
      textQuestionsLimit,
      voiceMinutesUsed,
      voiceMinutesLimit,
      imageScansUsed,
      imageScansLimit,
      resetDate,
    );
  }
}
