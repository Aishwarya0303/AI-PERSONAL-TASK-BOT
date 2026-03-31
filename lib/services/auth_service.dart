import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // ─── Email & Password Sign In ───────────────────────────────────────────────

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveUserToFirestore(credential.user!);
    return credential;
  }

  // ─── Email & Password Register ──────────────────────────────────────────────

  Future<UserCredential> registerWithEmail(
      String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();

    // Save to Firestore
    await _saveUserToFirestore(credential.user!);
    return credential;
  }

  // ─── Reset Password ─────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Google Sign In ─────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      await _saveUserToFirestore(userCredential.user!);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ─── Save User to Firestore ─────────────────────────────────────────────────

  Future<void> _saveUserToFirestore(User user) async {
    final userDoc =
        _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // ─── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Get User Data ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    return doc.data();
  }
}
