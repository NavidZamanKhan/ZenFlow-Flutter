import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Web Client ID (used as serverClientId so Google returns an id_token for Django)
  static const String webClientId =
      '680417209345-e220tanmhq34htb6dhs61glak7gc2n87.apps.googleusercontent.com';

  // iOS Client ID
  static const String iosClientId =
      '680417209345-9c06kkp0scqgvhelptme63t1hd4e3653.apps.googleusercontent.com';

  // Android Client ID
  static const String androidClientId =
      '680417209345-f15slv6fprp1ud679l8701qmn2lrhlf2.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: Platform.isIOS
                  ? iosClientId
                  : (Platform.isAndroid ? androidClientId : null),
              serverClientId: webClientId,
              scopes: const ['email', 'profile', 'openid'],
            );

  /// Performs Google Sign-In and returns the idToken (and optional accessToken)
  Future<GoogleAuthResult?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the login flow
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      return GoogleAuthResult(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out of Google session
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}

class GoogleAuthResult {
  final String? idToken;
  final String? accessToken;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAuthResult({
    required this.idToken,
    this.accessToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}
