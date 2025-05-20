abstract class SyncableModel {
  /// model ID
  String get id;

  /// Indicates whether the model is synchronized with the server
  bool get isSynced;

  /// Model creation date
  DateTime get createdAt;

  /// Date of last modification of the model
  DateTime get updatedAt;

  /// Converts the model to a Map for serialization
  Map<String, dynamic> toJson();

  /// Creates a copy of the template with the specified modifications
  SyncableModel copyWith({bool? isSynced});
}
