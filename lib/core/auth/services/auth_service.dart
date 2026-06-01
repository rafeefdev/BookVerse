import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_service.dart';

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

class AuthService {
  Future<void> signInWithGoogle() async {
    if (Platform.isAndroid) {
      await _signInWithAndroid();
    } else {
      await _signInWithLinux();
    }
  }

  Future<void> _signInWithAndroid() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    if (webClientId == null || webClientId.isEmpty) {
      throw const AuthException('GOOGLE_WEB_CLIENT_ID not configured');
    }

    final googleSignIn = GoogleSignIn(serverClientId: webClientId);
    final account = await googleSignIn.signIn();
    if (account == null) throw const AuthCancelledException();

    final auth = await account.authentication;
    if (auth.idToken == null) {
      throw const AuthException('Failed to obtain Google ID token');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: auth.idToken!,
      accessToken: auth.accessToken,
    );
  }

  Future<void> _signInWithLinux() async {
    final server = await HttpServer.bind('127.0.0.1', 0);
    final port = server.port;

    final oauthUrl = await supabase.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: 'http://127.0.0.1:$port',
    );

    final completer = Completer<String>();

    server.listen(
      (request) {
        final code = request.uri.queryParameters['code'];
        if (code != null) {
          completer.complete(code);
        } else {
          completer.completeError(
            const AuthException('No auth code in callback'),
          );
        }
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write('Login successful! Close this tab.')
          ..close();
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    await launchUrl(Uri.parse(oauthUrl.url));

    final code = await completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => throw const AuthException('Login timed out'),
    );

    await server.close();
    await supabase.auth.exchangeCodeForSession(code);
  }

  Future<void> signOut() => supabase.auth.signOut();

  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;
}
