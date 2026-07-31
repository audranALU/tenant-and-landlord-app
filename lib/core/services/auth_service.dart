import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// SIGN IN with email + password
  Future<firebase_auth.UserCredential?> signInWithEmail(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// CREATE ACCOUNT with email + password, then write the user's
  /// role document to Firestore. This is what makes role routing work.
  Future<firebase_auth.UserCredential?> createAccount({
    required String email,
    required String password,
    required String name,
    required String role, // "tenant" | "landlord" | "technician"
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // Save the role to Firestore so we can route the user after login.
    final userModel = UserModel(
      uid: uid,
      email: email,
      name: name,
      role: role,
    );

    await _firestore.collection("users").doc(uid).set(userModel.toMap());

    return userCredential;
  }

  /// SIGN IN with Google. New Google users default to "tenant" role;
  /// existing users keep their stored role.
  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    // If this is the first Google sign-in, create a user document.
    final uid = userCredential.user!.uid;
    final doc = await _firestore.collection("users").doc(uid).get();
    if (!doc.exists) {
      final userModel = UserModel(
        uid: uid,
        email: userCredential.user!.email ?? "",
        name: userCredential.user!.displayName ?? "",
        role: "tenant", // default; can be changed later
      );
      await _firestore.collection("users").doc(uid).set(userModel.toMap());
    }

    return userCredential;
  }

  /// READ the user's role document from Firestore.
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// PASSWORD RESET — sends a reset email.
  Future<void> sendPasswordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
