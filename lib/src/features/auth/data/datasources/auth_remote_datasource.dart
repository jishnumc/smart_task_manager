import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_task_manager/src/features/auth/data/models/user_model.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<void> signOut();
  Future<UserModel> updateUserProfile({
    required String name,
    String? themeMode,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _usersRef.doc(currentUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        // Fallback user model if Firestore doc hasn't been created yet
        return UserModel(
          id: currentUser.uid,
          email: currentUser.email ?? '',
          name: currentUser.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch user profile', e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Authentication failed. User is null.');
      }

      final doc = await _usersRef.doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        final newUserModel = UserModel(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? email.split('@').first,
          createdAt: DateTime.now(),
        );
        await _usersRef.doc(user.uid).set(newUserModel.toFirestore());
        return newUserModel;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthCode(e.code, e.message);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', e.code);
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Registration failed. User is null.');
      }

      await user.updateDisplayName(name.trim());

      final newUserModel = UserModel(
        id: user.uid,
        email: user.email ?? email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );

      await _usersRef.doc(user.uid).set(newUserModel.toFirestore());

      return newUserModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthCode(e.code, e.message);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', e.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthCode(e.code, e.message);
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String name,
    String? themeMode,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw const AuthException('No user logged in to update profile.');
    }

    try {
      final updates = <String, dynamic>{
        'name': name.trim(),
      };

      if (themeMode != null) {
        updates['themeMode'] = themeMode;
      }

      await _usersRef.doc(currentUser.uid).update(updates);
      await currentUser.updateDisplayName(name.trim());

      final updatedDoc = await _usersRef.doc(currentUser.uid).get();
      return UserModel.fromFirestore(updatedDoc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update profile', e.code);
    }
  }
}
