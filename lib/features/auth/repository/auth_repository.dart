import 'package:book_verse/core/models/authuser_model.dart';
import 'package:book_verse/core/providers/supabase_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepository(supabase);
});

class AuthRepository {
  final SupabaseClient supabase;

  AuthRepository(this.supabase);

  String? googleClientID =  dotenv.env['GOOGLE_CLIENT_ID_WEB'];

  // // Helper to get the correct client ID based on the platform
  // String? get _googleClientId {
  //   if (kIsWeb) {
  //     return dotenv.env['GOOGLE_CLIENT_ID_WEB'];
  //   }
  //   if (Platform.isAndroid) {
  //     return dotenv.env['GOOGLE_CLIENT_ID_WEB'];
  //   }
  //   if (Platform.isLinux) {}
  //   // For other platforms like iOS, Desktop, etc.
  //   // You might need different client IDs
  //   return null;
  // }

  Future<Authuser?> signInWithGoogle() async {
    try {
      // 1. Initialize GoogleSignIn with the correct serverClientId
      final googleSignIn = GoogleSignIn(
        serverClientId: googleClientID,
        scopes: ['email'],
      );

      // 2. Start the sign-in process
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // 3. Get the authentication tokens
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Failed to get ID token from Google.';
      }

      // 4. Sign in to Supabase with the tokens
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw 'Supabase sign-in failed.';
      }

      // 5. Return your custom user model
      return Authuser(
        name: user.userMetadata?['name'] ?? '',
        email: user.email!,
      );
    } catch (e) {
      // Log the error for debugging
      debugPrint('Error during Google sign-in: $e');
      // Optionally, sign out to ensure a clean state
      // await GoogleSignIn().signOut();
      // await supabase.auth.signOut();
      return null;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await GoogleSignIn().signOut();
  }
}
