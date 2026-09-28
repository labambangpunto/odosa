import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_signin;

// Wrapper HttpClient untuk menyisipkan header token dari google_sign_in
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleAuthService {
  static const _scopes = [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ];
  static final g_signin.GoogleSignIn _googleSignIn = g_signin.GoogleSignIn(
    scopes: _scopes,
  );
  // Kredensial Desktop dari Google Cloud Console
  // Data ini belum terverifikasi secara fungsional hingga Anda memasukkan Client ID asli
  static const String _desktopClientId = 'GANTI_DENGAN_DESKTOP_CLIENT_ID';

  static Future<http.Client?> getAuthenticatedClient() async {
    if (Platform.isAndroid) {
      // Alur Android
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final authHeaders = await account.authHeaders;
      return GoogleAuthClient(authHeaders);
    } else if (Platform.isLinux || Platform.isWindows) {
      // Alur Desktop (PKCE)
      var clientId = ClientId(_desktopClientId, '');

      try {
        AuthClient authClient = await clientViaUserConsent(clientId, _scopes, (
          url,
        ) async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            // Fallback instruksi CLI jika browser gagal dibuka
            stdout.writeln('Buka tautan berikut di browser Anda: $url');
          }
        });
        return authClient;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> signOut() async {
    if (Platform.isAndroid) {
      await _googleSignIn.signOut();
    } else {
      // Pencabutan token untuk desktop dilakukan dengan mengosongkan kredensial tersimpan
      // (Memerlukan implementasi persistent storage tersendiri)
    }
  }
}
