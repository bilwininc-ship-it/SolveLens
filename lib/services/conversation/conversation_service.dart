// Conversation Service for managing chat conversations in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/chat_message_model.dart';

class ConversationService {
  final FirebaseFirestore _firestore;

  ConversationService(this._firestore);

  /// Creates a new conversation
  Future<ConversationModel> createConversation({
    required String userId,
    required String title,
    ChatMode mode = ChatMode.textToText,
  }) async {
    try {
      final conversationRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc();

      final conversation = ConversationModel(
        id: conversationRef.id,
        userId: userId,
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageCount: 0,
        mode: mode,
      );

      await conversationRef.set(conversation.toFirestore());
      return conversation;
    } catch (e) {
      throw ConversationServiceException('Failed to create conversation: $e');
    }
  }

  /// Gets all conversations for a user
  Future<List<ConversationModel>> getConversations({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ConversationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ConversationServiceException('Failed to fetch conversations: $e');
    }
  }

  /// Gets a specific conversation
  Future<ConversationModel?> getConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) return null;
      return ConversationModel.fromFirestore(doc);
    } catch (e) {
      throw ConversationServiceException('Failed to fetch conversation: $e');
    }
  }

  /// Updates a conversation
  Future<void> updateConversation({
    required String userId,
    required String conversationId,
    String? title,
    String? lastMessage,
    int? messageCount,
    ChatMode? mode,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updates['title'] = title;
      if (lastMessage != null) updates['lastMessage'] = lastMessage;
      if (messageCount != null) updates['messageCount'] = messageCount;
      if (mode != null) updates['mode'] = mode.toString();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .update(updates);
    } catch (e) {
      throw ConversationServiceException('Failed to update conversation: $e');
    }
  }

  /// Deletes a conversation and all its messages
  Future<void> deleteConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      // Delete all messages in this conversation
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the conversation itself
      final conversationRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId);
      batch.delete(conversationRef);

      await batch.commit();
    } catch (e) {
      throw ConversationServiceException('Failed to delete conversation: $e');
    }
  }

  /// Saves a message to a conversation
  Future<void> saveMessage({
    required String userId,
    required String conversationId,
    required ChatMessageModel message,
  }) async {
    try {
      // Save message
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id)
          .set({
        'id': message.id,
        'text': message.text,
        'isUser': message.isUser,
        'timestamp': Timestamp.fromDate(message.timestamp),
        'hasImage': message.hasImage,
        'hasAudio': message.hasAudio,
        'hasPDF': message.hasPDF,
        'audioUrl': message.audioUrl,
        'pdfFileName': message.pdfFileName,
        'pdfFileSize': message.pdfFileSize,
      });

      // Update conversation metadata
      await updateConversation(
        userId: userId,
        conversationId: conversationId,
        lastMessage: message.text.length > 50
            ? '${message.text.substring(0, 50)}...'
            : message.text,
      );
    } catch (e) {
      throw ConversationServiceException('Failed to save message: $e');
    }
  }

  /// Gets messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw ConversationServiceException('Failed to fetch messages: $e');
    }
  }

  /// Streams conversations for real-time updates
  Stream<List<ConversationModel>> streamConversations({
    required String userId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList());
  }
}

/// Custom exception for Conversation Service errors
class ConversationServiceException implements Exception {
  final String message;
  ConversationServiceException(this.message);

  @override
  String toString() => message;
}
