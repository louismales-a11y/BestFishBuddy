import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/catch.dart';

/// Handles cloud sync of catch data via Firebase.
/// Keeps local SQLite as primary storage, syncs to cloud in background.
class FirebaseSyncService {
  static final FirebaseSyncService instance = FirebaseSyncService._();
  FirebaseSyncService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
  User? get user => FirebaseAuth.instance.currentUser;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed';
    }
  }

  Future<void> signOut() async => FirebaseAuth.instance.signOut();

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  Future<void> uploadCatch(Catch c, {String? shareWithEmail}) async {
    if (!isLoggedIn) return;
    final uid = user!.uid;
    final data = c.toMap();
    data['userId'] = uid;
    data['sharedBy'] = user!.email;
    data['syncedAt'] = FieldValue.serverTimestamp();
    data.remove('id');

    // Upload to own collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('catches')
        .add(data);

    // If sharing with another user, write to their shared collection
    if (shareWithEmail != null && shareWithEmail.isNotEmpty) {
      final sharedUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: shareWithEmail)
          .limit(1)
          .get();
      if (sharedUser.docs.isNotEmpty) {
        final sharedUid = sharedUser.docs.first.id;
        data['sharedFrom'] = user!.email;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(sharedUid)
            .collection('shared_catches')
            .add(data);
      }
    }
  }

  /// Save user email lookup on sign up
  Future<void> saveUserEmail() async {
    if (!isLoggedIn) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set({'email': user!.email}, SetOptions(merge: true));
  }

  /// Fetch catches shared with me
  Future<List<Catch>> fetchSharedCatches() async {
    if (!isLoggedIn) return [];
    final uid = user!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('shared_catches')
        .orderBy('caught_at', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id.hashCode;
      return Catch.fromMap(data);
    }).toList();
  }

  Future<void> uploadPhoto(String localPath, String catchId) async {
    if (!isLoggedIn) return;
    final file = File(localPath);
    if (!file.existsSync()) return;
    final uid = user!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/$uid/catches/$catchId/${file.uri.pathSegments.last}');
    await ref.putFile(file);
  }

  Future<List<Catch>> fetchCloudCatches() async {
    if (!isLoggedIn) return [];
    final uid = user!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('catches')
        .orderBy('caught_at', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id.hashCode; // dummy id for cloud-only catches
      return Catch.fromMap(data);
    }).toList();
  }
}
