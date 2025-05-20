import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/repositories/offline_repository_base.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../models/note_model.dart';

@lazySingleton
class NoteRepository extends OfflineRepositoryBase<NoteModel> {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  // Clé pour stocker les notes dans SharedPreferences
  static const String _notesKey = 'offline_notes';

  // Clé pour stocker les opérations en attente dans SharedPreferences
  static const String _pendingOperationsKey = 'pending_note_operations';

  NoteRepository(this._firestore, this._prefs, ConnectivityService connectivityService)
    : super(connectivityService) {
    // Charger les opérations en attente depuis le stockage local
    _loadPendingOperations();
  }

  // Collection Firestore pour les notes
  CollectionReference<Map<String, dynamic>> get _notesCollection => _firestore.collection('notes');

  // Créer une nouvelle note
  Future<NoteModel> createNote(String title, String content) async {
    final note = NoteModel(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    // Sauvegarder localement
    await saveLocally(note);

    // Si nous sommes en ligne, synchroniser avec le serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await _saveToFirestore(note);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.create,
          data: note,
          execute: () => _saveToFirestore(note),
        ),
      );

      // Sauvegarder les opérations en attente
      await _savePendingOperations();
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
      await _saveToFirestore(updatedNote);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.update,
          data: updatedNote,
          execute: () => _saveToFirestore(updatedNote),
        ),
      );

      // Sauvegarder les opérations en attente
      await _savePendingOperations();
    }

    return updatedNote;
  }

  // Supprimer une note
  Future<void> deleteNote(String noteId) async {
    // Supprimer localement
    final notes = await loadLocally();
    final updatedNotes = notes.where((note) => note.id != noteId).toList();

    final notesJson = updatedNotes.map((note) => jsonEncode(note.toJson())).toList();
    await _prefs.setStringList(_notesKey, notesJson);

    // Si nous sommes en ligne, supprimer du serveur
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await _deleteFromFirestore(noteId);
    } else {
      // Sinon, ajouter à la file d'attente des opérations en attente
      final noteToDelete = notes.firstWhere((note) => note.id == noteId);
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.delete,
          data: noteToDelete,
          execute: () => _deleteFromFirestore(noteId),
        ),
      );

      // Sauvegarder les opérations en attente
      await _savePendingOperations();
    }
  }

  // Obtenir toutes les notes
  Future<List<NoteModel>> getNotes() async {
    try {
      // Si nous sommes en ligne, essayer de récupérer depuis Firestore
      if (connectivityService.currentStatus == ConnectionStatus.online) {
        final snapshot = await _notesCollection.get();
        final notes = snapshot.docs.map((doc) => NoteModel.fromJson(doc.data())).toList();

        // Mettre à jour le stockage local avec les données du serveur
        final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
        await _prefs.setStringList(_notesKey, notesJson);

        return notes;
      } else {
        // Sinon, charger depuis le stockage local
        return loadLocally();
      }
    } catch (e) {
      AppLogger.error('Error getting notes', e);
      // En cas d'erreur, charger depuis le stockage local
      return loadLocally();
    }
  }

  // Sauvegarder une note dans Firestore
  Future<void> _saveToFirestore(NoteModel note) async {
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

  // Supprimer une note de Firestore
  Future<void> _deleteFromFirestore(String noteId) async {
    try {
      await _notesCollection.doc(noteId).delete();
      AppLogger.debug('Note deleted from Firestore: $noteId');
    } catch (e) {
      AppLogger.error('Error deleting note from Firestore', e);
      rethrow;
    }
  }

  @override
  Future<List<NoteModel>> loadLocally() async {
    try {
      final notesJson = _prefs.getStringList(_notesKey) ?? [];
      return notesJson.map((json) => NoteModel.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      AppLogger.error('Error loading notes locally', e);
      return [];
    }
  }

  @override
  Future<void> saveLocally(NoteModel data) async {
    try {
      final notes = await loadLocally();

      // Vérifier si la note existe déjà
      final index = notes.indexWhere((note) => note.id == data.id);

      if (index >= 0) {
        // Mettre à jour la note existante
        notes[index] = data;
      } else {
        // Ajouter la nouvelle note
        notes.add(data);
      }

      // Sauvegarder la liste mise à jour
      final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
      await _prefs.setStringList(_notesKey, notesJson);

      AppLogger.debug('Note saved locally: ${data.id}');
    } catch (e) {
      AppLogger.error('Error saving note locally', e);
      rethrow;
    }
  }

  @override
  Future<void> syncWithServer() async {
    try {
      // Traiter les opérations en attente
      await processPendingOperations();

      // Récupérer les notes depuis le serveur
      final snapshot = await _notesCollection.get();
      final serverNotes = snapshot.docs.map((doc) => NoteModel.fromJson(doc.data())).toList();

      // Récupérer les notes locales
      final localNotes = await loadLocally();

      // Identifier les notes qui existent localement mais pas sur le serveur
      final localOnlyNotes =
          localNotes.where((local) => !serverNotes.any((server) => server.id == local.id)).toList();

      // Synchroniser les notes locales uniquement avec le serveur
      for (final note in localOnlyNotes) {
        if (!note.isSynced) {
          await _saveToFirestore(note);
        }
      }

      // Mettre à jour le stockage local avec toutes les notes
      final allNotes = [...serverNotes, ...localOnlyNotes];
      final notesJson = allNotes.map((note) => jsonEncode(note.toJson())).toList();
      await _prefs.setStringList(_notesKey, notesJson);

      AppLogger.info('Notes synchronized with server');
    } catch (e) {
      AppLogger.error('Error synchronizing notes with server', e);
      rethrow;
    }
  }

  // Charger les opérations en attente depuis le stockage local
  void _loadPendingOperations() {
    try {
      final pendingOpsJson = _prefs.getStringList(_pendingOperationsKey) ?? [];

      for (final json in pendingOpsJson) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final type = OperationType.values[map['type'] as int];
        final noteData = map['data'] as Map<String, dynamic>;
        final note = NoteModel.fromJson(noteData);

        switch (type) {
          case OperationType.create:
          case OperationType.update:
            addPendingOperation(
              PendingOperation<NoteModel>(
                type: type,
                data: note,
                execute: () => _saveToFirestore(note),
              ),
            );
            break;
          case OperationType.delete:
            addPendingOperation(
              PendingOperation<NoteModel>(
                type: type,
                data: note,
                execute: () => _deleteFromFirestore(note.id),
              ),
            );
            break;
        }
      }

      AppLogger.debug('Loaded ${pendingOpsJson.length} pending operations');
    } catch (e) {
      AppLogger.error('Error loading pending operations', e);
    }
  }

  // Sauvegarder les opérations en attente dans le stockage local
  Future<void> _savePendingOperations() async {
    try {
      final pendingOpsJson =
          pendingOperations.map((op) {
            return jsonEncode({'type': op.type.index, 'data': op.data.toJson()});
          }).toList();

      await _prefs.setStringList(_pendingOperationsKey, pendingOpsJson);
      AppLogger.debug('Saved ${pendingOpsJson.length} pending operations');
    } catch (e) {
      AppLogger.error('Error saving pending operations', e);
    }
  }
}
