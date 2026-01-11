// Notes Service for managing saved notes in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/saved_note_model.dart';

class NotesService {
  final FirebaseFirestore _firestore;

  NotesService(this._firestore);

  /// Saves a note to Firestore
  /// Path: users/{uid}/notes/{noteId}
  Future<void> saveNote({
    required String userId,
    required String imageUrl,
    required String solutionText,
    required String question,
    required String subject,
  }) async {
    try {
      final noteRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc();

      final note = SavedNoteModel(
        id: noteRef.id,
        userId: userId,
        imageUrl: imageUrl,
        solutionText: solutionText,
        question: question,
        subject: subject,
        createdAt: DateTime.now(),
      );

      await noteRef.set(note.toFirestore());
    } catch (e) {
      throw NotesServiceException('Failed to save note: $e');
    }
  }

  /// Fetches all notes for a user, sorted by newest first
  Future<List<SavedNoteModel>> getNotes({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedNoteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw NotesServiceException('Failed to fetch notes: $e');
    }
  }

  /// Deletes a specific note
  Future<void> deleteNote({
    required String userId,
    required String noteId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      throw NotesServiceException('Failed to delete note: $e');
    }
  }

  /// Checks if a note with this solution already exists
  Future<bool> noteExists({
    required String userId,
    required String question,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('question', isEqualTo: question)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for Notes Service errors
class NotesServiceException implements Exception {
  final String message;
  NotesServiceException(this.message);

  @override
  String toString() => message;
}
