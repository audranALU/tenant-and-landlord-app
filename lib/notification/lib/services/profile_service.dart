import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// Backs the ProfileScreen header (name, photo, Premium badge) and the
/// Properties / Active Tasks stat cards.
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users').doc(_uid);

  Stream<UserProfile?> streamProfile() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
  }

  Future<UserProfile?> getProfileOnce() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? UserProfile.fromFirestore(doc) : null;
  }

  /// Creates the user doc with sane defaults the first time someone
  /// signs in (call this right after sign-up/sign-in).
  Future<void> ensureProfileExists({required String name, String? photoUrl}) async {
    final uid = _uid;
    if (uid == null) return;
    final doc = await _doc.get();
    if (!doc.exists) {
      await _doc.set({
        'name': name,
        'photoUrl': photoUrl,
        'isPremium': false,
        'propertiesCount': 0,
        'activeTasksCount': 0,
        'fcmTokens': [],
        'settings': {
          'pushNotifications': true,
          'emailAlerts': false,
          'darkMode': false,
          'lowDataMode': false,
        },
      });
    }
  }

  Future<void> updateName(String name) => _doc.update({'name': name});

  Future<void> updatePhoto(String photoUrl) =>
      _doc.update({'photoUrl': photoUrl});
}
