import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations using Firebase Auth.
abstract class AuthRemoteDataSource {
  /// Sign in with email and password.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Get the current authenticated user.
  Future<UserModel?> getCurrentUser();

  /// Stream of authentication state changes.
  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
  );

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }

      return await _getUserFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e));
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Sign up failed: No user returned');
      }

      // Update display name if provided
      if (displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Create user document in Firestore
      final now = DateTime.now();
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'email': email,
        'displayName': displayName.isNotEmpty ? displayName : null,
        'photoUrl': null,
        'roles': const ['attendee'],
        'organizationId': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': null,
      });

      return await _getUserFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e));
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await _getUserFromFirebase(user);
    } catch (e) {
      throw AuthException('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _getUserFromFirebase(firebaseUser);
      } catch (e) {
        return null;
      }
    });
  }

  /// Get user data from Firestore or create from Firebase Auth user.
  Future<UserModel> _getUserFromFirebase(firebase_auth.User firebaseUser) async {
    try {
      // Try to get user from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? data['email'] ?? '',
          displayName: data['displayName'] ?? firebaseUser.displayName,
          photoUrl: data['photoUrl'] ?? firebaseUser.photoURL,
          roles: List<String>.from(data['roles'] ?? ['attendee']),
          organizationId: data['organizationId'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
              firebaseUser.metadata.creationTime ??
              DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        );
      } else {
        // User doesn't exist in Firestore, create basic user from Firebase Auth
        final now = DateTime.now();
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          roles: const ['attendee'],
          organizationId: null,
          createdAt: firebaseUser.metadata.creationTime ?? now,
          updatedAt: null,
        );
      }
    } catch (e) {
      // Fallback to Firebase Auth user data if Firestore fails
      final now = DateTime.now();
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        roles: const ['attendee'],
        organizationId: null,
        createdAt: firebaseUser.metadata.creationTime ?? now,
        updatedAt: null,
      );
    }
  }

  /// Convert Firebase Auth exception to user-friendly error message.
  String _getAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

