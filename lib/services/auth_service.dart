import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenxo/models/user_model.dart';
import 'package:expenxo/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserModel?> signUp(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
        );

        // Save user to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

        notifyListeners();
        return newUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error signing up: $e");
      }
      rethrow;
    }
    return null;
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error signing in: $e");
      }
      rethrow;
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // For Web, explicitly passing clientId can be helpful if meta tag issue persists,
      // though typically meta tag is preferred. We do both for robustness given the user's error.
      // NOTE: For other platforms, we let GoogleServices-Info.plist / google-services.json handle it (clientId null).
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '38822547498-sq407jchg9suk3pq2spmfpgjvk1t3jpc.apps.googleusercontent.com'
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        User? user = userCredential.user;

        if (user != null) {
          // Check if user exists in Firestore, if not create
          final userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (!userDoc.exists) {
            UserModel newUser = UserModel(
              uid: user.uid,
              email: user.email!,
              name: user.displayName ?? 'No Name',
            );
            await _firestore
                .collection('users')
                .doc(user.uid)
                .set(newUser.toMap());
          }
          notifyListeners();
          return user;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error signing in with Google: $e");
      }
      rethrow;
    }
    return null;
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print("Error sending password reset email: $e");
      }
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Clear local cache on logout
    await LocalStorageService().clearCache();

    notifyListeners();
  }
}
