import 'package:duolingo/src/firebase/api_response.dart';
import 'package:duolingo/src/model/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ApiResponse<model.User>> loginGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResponse.error(message: "Login cancelado");
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Google User: ${googleUser.email}");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? fuser = result.user;

      if (fuser == null) {
          return ApiResponse.error(message: "Erro ao obter usuário do Firebase");
      }

      print("Firebase Nome: ${fuser.displayName}");
      print("Firebase Email: ${fuser.email}");
      print("Firebase Foto: ${fuser.photoURL}");

      final user = model.User(
        name: fuser.displayName,
        login: fuser.email,
        email: fuser.email,
        urlPhoto: fuser.photoURL,
      );
      user.save();

      return ApiResponse.ok(result: user);
    } catch (error) {
      print("Firebase error $error");
      return ApiResponse.error(message: "Não foi possível fazer o login");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
