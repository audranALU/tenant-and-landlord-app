import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();



  Future<UserCredential?> signInWithEmail(
      String email,
      String password,
      ) async {

    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

  }

Future<UserCredential?> createAccount(
  String email,
  String password,
) async {

  try {

    UserCredential userCredential =
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

    return userCredential;

  } catch (e) {

    print("Register error: $e");

    return null;

  }

}

  Future<UserCredential?> signInWithGoogle() async {

    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();


    if (googleUser == null) {
      return null;
    }


    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;


    final credential =
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );


    return await _firebaseAuth.signInWithCredential(
      credential,
    );

  }



  Future<void> signOut() async {

    await _firebaseAuth.signOut();

  }

}