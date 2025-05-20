abstract class SyncableModel {
  /// Identifiant unique du modèle
  String get id;

  /// Indique si le modèle est synchronisé avec le serveur
  bool get isSynced;

  /// Date de création du modèle
  DateTime get createdAt;

  /// Date de dernière modification du modèle
  DateTime get updatedAt;

  /// Convertit le modèle en Map pour la sérialisation
  Map<String, dynamic> toJson();

  /// Crée une copie du modèle avec les modifications spécifiées
  SyncableModel copyWith({bool? isSynced});
}
