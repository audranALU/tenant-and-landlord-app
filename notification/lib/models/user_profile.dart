import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `/users/{uid}` — the profile header + stat cards on ProfileScreen.
class UserProfile {
  final String uid;
  final String name;
  final String? photoUrl;
  final bool isPremium;
  final int propertiesCount;
  final int activeTasksCount;
  final List<String> fcmTokens;

  UserProfile({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.isPremium = false,
    this.propertiesCount = 0,
    this.activeTasksCount = 0,
    this.fcmTokens = const [],
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      isPremium: data['isPremium'] ?? false,
      propertiesCount: data['propertiesCount'] ?? 0,
      activeTasksCount: data['activeTasksCount'] ?? 0,
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
    );
  }
}
