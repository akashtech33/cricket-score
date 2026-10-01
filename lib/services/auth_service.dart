import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static const String adminEmail = 'akash@gmail.com';
  static const String adminPassword = 'akash1234';

  // Local demo fallback memory (used if Firebase project is offline or not yet connected)
  static final Map<String, UserModel> _mockUsers = {
    'akash@gmail.com': UserModel(
      uid: 'admin_akash_main',
      name: 'Akash (Admin)',
      email: 'akash@gmail.com',
      role: UserRole.admin,
    ),
    'admin@cricket.com': UserModel(
      uid: 'mock_admin_1',
      name: 'Match Referee (Admin)',
      email: 'admin@cricket.com',
      role: UserRole.admin,
    ),
    'user@cricket.com': UserModel(
      uid: 'mock_audience_1',
      name: 'Cricket Fan',
      email: 'user@cricket.com',
      role: UserRole.audience,
    ),
  };

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isAdminEmail(String email) {
    final clean = email.trim().toLowerCase();
    return clean == adminEmail || clean == 'admin@cricket.com';
  }

  /// Sign In with Email and Password
  Future<UserModel> signIn(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try Firebase Authentication first
    final auth = _auth;
    final firestore = _firestore;
    if (auth != null && firestore != null) {
      try {
        final userCredential = await auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          final doc = await firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final role = _isAdminEmail(cleanEmail) ? UserRole.admin : UserModel.fromMap(doc.data()!, user.uid).role;
            _currentUser = UserModel(
              uid: user.uid,
              name: doc.data()?['name'] ?? (user.displayName ?? (cleanEmail == adminEmail ? 'Akash (Admin)' : cleanEmail.split('@').first)),
              email: cleanEmail,
              role: role,
            );
            return _currentUser!;
          } else {
            final defaultRole = _isAdminEmail(cleanEmail) ? UserRole.admin : UserRole.audience;
            final newUser = UserModel(
              uid: user.uid,
              name: user.displayName ?? (cleanEmail == adminEmail ? 'Akash (Admin)' : cleanEmail.split('@').first),
              email: cleanEmail,
              role: defaultRole,
            );
            await firestore.collection('users').doc(user.uid).set(newUser.toMap());
            _currentUser = newUser;
            return _currentUser!;
          }
        }
      } catch (e) {
        debugPrint('Firebase Auth attempt notice: $e');
        // Auto-provision designated admin in Firebase if user doesn't exist yet
        if (cleanEmail == adminEmail && password == adminPassword) {
          try {
            final userCredential = await auth.createUserWithEmailAndPassword(
              email: cleanEmail,
              password: password,
            );
            final user = userCredential.user;
            if (user != null) {
              await user.updateDisplayName('Akash (Admin)');
              final newAdmin = UserModel(
                uid: user.uid,
                name: 'Akash (Admin)',
                email: cleanEmail,
                role: UserRole.admin,
              );
              await firestore.collection('users').doc(user.uid).set(newAdmin.toMap());
              _currentUser = newAdmin;
              return newAdmin;
            }
          } catch (createErr) {
            debugPrint('Firebase admin auto-provision notice: $createErr');
          }
        }
      }
    }

    // 2. Local fallback memory
    if (cleanEmail == adminEmail) {
      if (password != adminPassword) {
        throw Exception('Invalid password for $adminEmail');
      }
      _currentUser = _mockUsers[adminEmail];
      return _currentUser!;
    }

    if (_mockUsers.containsKey(cleanEmail)) {
      _currentUser = _mockUsers[cleanEmail];
      return _currentUser!;
    }

    // If new demo user
    final fallbackRole = _isAdminEmail(cleanEmail) ? UserRole.admin : UserRole.audience;
    final fallbackUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanEmail.split('@').first.toUpperCase(),
      email: cleanEmail,
      role: fallbackRole,
    );
    _mockUsers[cleanEmail] = fallbackUser;
    _currentUser = fallbackUser;
    return _currentUser!;
  }

  /// Sign Up with Name, Email, Password, and Role
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    final auth = _auth;
    final firestore = _firestore;
    if (auth != null && firestore != null) {
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(name);
          final newUser = UserModel(
            uid: user.uid,
            name: name,
            email: cleanEmail,
            role: role,
          );

          // Store role securely in Firestore users/{userId}
          await firestore.collection('users').doc(user.uid).set(newUser.toMap());
          _currentUser = newUser;
          return newUser;
        }
      } catch (e) {
        debugPrint('Firebase SignUp attempt notice: $e');
      }
    }

    // Fallback store
    final fallbackUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: cleanEmail,
      role: role,
    );
    _mockUsers[cleanEmail] = fallbackUser;
    _currentUser = fallbackUser;
    return fallbackUser;
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
    _currentUser = null;
  }
}
