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

  // Firestore collection for notes
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

  // Create a new note
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

    // Save locally
    await saveLocally(note);

    // If we are online, synchronize with the server
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(note);
    } else {
      // Otherwise, add to the pending operations queue
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.create,
          data: note,
          execute: () => saveToRemote(note),
        ),
      );

      // Save pending operations
      await savePendingOperations();
    }

    return note;
  }

  // Update an existing note
  Future<NoteModel> updateNote(NoteModel note) async {
    final updatedNote = note.copyWith(updatedAt: DateTime.now(), isSynced: false);

    // Save locally
    await saveLocally(updatedNote);

    // If we are online, synchronize with the server
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await saveToRemote(updatedNote);
    } else {
      // Otherwise, add to the pending operations queue
      addPendingOperation(
        PendingOperation<NoteModel>(
          type: OperationType.update,
          data: updatedNote,
          execute: () => saveToRemote(updatedNote),
        ),
      );

      // Save pending operations
      await savePendingOperations();
    }

    return updatedNote;
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    // Delete locally
    await deleteLocally(noteId);

    // If we are online, delete from server
    if (connectivityService.currentStatus == ConnectionStatus.online) {
      await deleteFromRemote(noteId);
    } else {
      // Otherwise, add to the pending operations queue
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

      // Save pending operations
      await savePendingOperations();
    }
  }

  // Get all notes
  Future<List<NoteModel>> getNotes() async {
    try {
      // If we are online, try to retrieve from Firestore
      if (connectivityService.currentStatus == ConnectionStatus.online) {
        final notes = await loadAllFromRemote();

        // Update local storage with server data
        for (final note in notes) {
          await saveLocally(note.copyWith(isSynced: true));
        }

        return notes;
      } else {
        // Otherwise, load from local storage
        return loadAllLocally();
      }
    } catch (e) {
      AppLogger.error('Error getting notes', e);
      // In case of error, load from local storage
      return loadAllLocally();
    }
  }

  @override
  Future<void> saveToRemote(NoteModel note) async {
    try {
      final updatedNote = note.copyWith(isSynced: true);
      await _notesCollection.doc(note.id).set(updatedNote.toJson());

      // Update local storage with synchronized note
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
