import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/repositories/offline_repository_base.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/utils/logger.dart';
import '../models/note_model.dart';

@lazySingleton
class NoteRepository extends OfflineRepositoryBase<NoteModel> {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  // Collection Firestore pour les notes
  CollectionReference<Map<String, dynamic>> get _notesCollection => _firestore.collection('notes');

  NoteRepository(
    this._firestore,
    LocalStorageService localStorageService,
    ConnectivityService connectivityService,
  ) : super(
        connectivityService: connectivityService,
        localStorageService: localStorageService,
        storageKey: 'offline_notes',
        pendingOperationsKey: 'pending_note_operations',
        fromJson: NoteModel.fromJson,
      );

  // Créer une nouvelle note
  Future<NoteModel> createNote(String title, String content, {String? userId}) async {
    final note = NoteModel(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      userId: userId,
    );

    // Sauvegarder localement
    await saveLocally(note);

    // Si nous sommes en ligne, synchroniser avec le serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(note);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.create,
          data: note,
          execute: () => saveToRemote(note),
        ),
      );

      // Sauvegarder les opérations en attente
      await savePendingOperations();
    }

    return note;
  }

  // Mettre à jour une note existante
  Future<NoteModel> updateNote(NoteModel note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now(), isSynced: false);

    // Sauvegarder localement
    await saveLocally(updatedNote);

    // Si nous sommes en ligne, synchroniser avec le serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(updatedNote);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.update,
          data: updatedNote,
          execute: () => saveToRemote(updatedNote),
        ),
      );

      // Sauvegarder les opérations en attente
      await savePendingOperations();
    }

    return updatedNote;
  }

  // Supprimer une note
  Future<void> deleteNote(String noteId) async {
    // Supprimer localement
    await deleteLocally(noteId);

    // Si nous sommes en ligne, supprimer du serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await deleteFromRemote(noteId);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      final notes = loadAllLocally();
      final noteToDelete = notes.firstWhere(
        (note) => note.id == noteId,
        orElse:
            () => NoteModel(
              id: noteId,
              title: '',
              content: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );

      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.delete,
          data: noteToDelete,
          execute: () => deleteFromRemote(noteId),
        ),
      );

      // Sauvegarder les opérations en attente
      await savePendingOperations();
    }
  }

  // Obtenir toutes les notes
  Future<List<NoteModel>> getNotes() async {
    try {
      // Si nous sommes en ligne, essayer de récupérer depuis Firestore
      if (connectivityService.currentStatus == ConnectionStatus.online) {
        final notes = await loadAllFromRemote();

        // Mettre à jour le stockage local avec les données du serveur
        for (final note in notes) {
          await saveLocally(note.copyWith(isSynced: true));
        }

        return notes;
      } else {
        // Sinon, charger depuis le stockage local
        return loadAllLocally();
      }
    } catch (e) {
      AppLogger.error('Error getting notes', e);
      // En cas d'erreur, charger depuis le stockage local
      return loadAllLocally();
    }
  }

  @override
  Future<void> saveToRemote(NoteModel note) async {
    try {
      final updatedNote = note.copyWith(isSynced: true);
      await _notesCollection.doc(note.id).set(updatedNote.toJson());

      // Mettre à jour le stockage local avec la note synchronisée
      await saveLocally(updatedNote);

      AppLogger.debug('Note saved to Firestore: ${note.id}');
    } catch (e) {
      AppLogger.error('Error saving note to Firestore', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteFromRemote(String id) async {
    try {
      await _notesCollection.doc(id).delete();
      AppLogger.debug('Note deleted from Firestore: $id');
    } catch (e) {
      AppLogger.error('Error deleting note from Firestore', e);
      rethrow;
    }
  }

  @override
  Future<List<NoteModel>> loadAllFromRemote() async {
    try {
      final snapshot = await _notesCollection.get();
      return snapshot.docs.map((doc) => NoteModel.fromJson(doc.data())).toList();
    } catch (e) {
      AppLogger.error('Error loading notes from Firestore', e);
      rethrow;
    }
  }
}
