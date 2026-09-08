import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/book_model.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;

  User? get currentUser => _auth?.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Initializes Firebase safely with graceful fallback if google-services.json
  /// or remote configuration is not yet set up on the host device.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[FirebaseService] Note: Firebase native config not detected: $e');
      debugPrint('[FirebaseService] Operating in local secure storage mode until Firebase is connected.');
    }
  }

  // ================= AUTHENTICATION =================

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!_isInitialized || _auth == null) {
      throw FirebaseUnavailableException(
        'Firebase is not configured yet. Set up google-services.json to use online authentication.',
      );
    }
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null && displayName.trim().isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
      }
      // Initialize user document in Firestore
      if (_firestore != null && credential.user != null) {
        await _firestore!.collection('users').doc(credential.user!.uid).set({
          'displayName': displayName.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized || _auth == null) {
      throw FirebaseUnavailableException(
        'Firebase is not configured yet. Set up google-services.json to use online authentication.',
      );
    }
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (_firestore != null && credential.user != null) {
        await _firestore!.collection('users').doc(credential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    if (_auth != null) {
      await _auth!.signOut();
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_isInitialized || _auth == null) {
      throw FirebaseUnavailableException(
        'Firebase is not configured yet.',
      );
    }
    try {
      await _auth!.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw AuthException('Could not send password reset email: $e');
    }
  }

  // ================= FIRESTORE SYNC =================

  /// Syncs a saved library book to users/{userId}/library/{bookId}
  Future<void> syncBookToLibrary(String userId, Book book) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('library')
          .doc(book.id)
          .set(book.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Error syncing book to Firestore: $e');
    }
  }

  /// Removes a book from users/{userId}/library/{bookId}
  Future<void> removeBookFromLibrary(String userId, String bookId) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('library')
          .doc(bookId)
          .delete();
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting book from Firestore: $e');
    }
  }

  /// Syncs reading progress to users/{userId}/readingProgress/{bookId}
  Future<void> syncReadingProgress({
    required String userId,
    required String bookId,
    required double progress,
    required double readingPosition,
    required bool isCompleted,
  }) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('readingProgress')
          .doc(bookId)
          .set({
        'bookId': bookId,
        'progress': progress,
        'readingPosition': readingPosition,
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Error syncing reading progress: $e');
    }
  }

  /// Records actual reading activity date to users/{userId}/readingActivity/{dateKey}
  Future<void> syncReadingActivity(String userId, String dateKey) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('readingActivity')
          .doc(dateKey)
          .set({
        'dateKey': dateKey,
        'readAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Error syncing reading activity: $e');
    }
  }

  /// Syncs user settings to users/{userId}/settings/preferences
  Future<void> syncSettings(String userId, Map<String, dynamic> settings) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set(settings, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Error syncing settings: $e');
    }
  }

  /// Translates raw Firebase exceptions into friendly, actionable messages
  static AuthException _translateAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No account found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException('Incorrect password. Please try again.');
      case 'email-already-in-use':
        return AuthException('An account already exists with this email.');
      case 'invalid-email':
        return AuthException('Please enter a valid email address.');
      case 'weak-password':
        return AuthException('Password is too weak. Use at least 6 characters.');
      case 'network-request-failed':
        return AuthException('Network error. Please check your connection.');
      case 'too-many-requests':
        return AuthException('Too many attempts. Please try again later.');
      default:
        return AuthException(e.message ?? 'Authentication error occurred.');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class FirebaseUnavailableException implements Exception {
  final String message;
  FirebaseUnavailableException(this.message);
  @override
  String toString() => message;
}
