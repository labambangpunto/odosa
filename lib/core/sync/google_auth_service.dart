import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleAuthService {
  static const _scopes = [drive.DriveApi.driveAppdataScope];
  final _secureStorage = const FlutterSecureStorage();

  static final _linuxClientId = ClientId(
    'CLIENT_ID_LINUX_ANDA.apps.googleusercontent.com',
    '',
  );
  final _googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<AuthClient> getAuthClient() async {
    if (Platform.isAndroid) {
      final GoogleSignInAccount? account =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

      if (account == null) {
        throw Exception('Otentikasi dibatalkan.');
      }

      final client = await _googleSignIn.authenticatedClient();
      if (client == null) {
        throw Exception('Gagal mendapatkan AuthClient dari Google Sign In.');
      }

      return client;
    } else if (Platform.isLinux) {
      final tokenString = await _secureStorage.read(key: 'gdrive_credentials');

      if (tokenString != null) {
        // Decode string JSON menjadi Map
        final credentials = AccessCredentials.fromJson(jsonDecode(tokenString));
        // Gunakan http.Client() untuk baseClient
        return autoRefreshingClient(_linuxClientId, credentials, http.Client());
      }

      final client = await clientViaUserConsent(_linuxClientId, _scopes, (url) {
        // Gunakan debugPrint untuk menghindari peringatan linter
        debugPrint('====================================================');
        debugPrint('BUKA URL BERIKUT DI BROWSER:');
        debugPrint(url);
        debugPrint('KEMUDIAN MASUKKAN KODE OTORISASI YANG MUNCUL');
        debugPrint('====================================================');
      });

      // Encode Map menjadi string JSON sebelum disimpan
      await _secureStorage.write(
        key: 'gdrive_credentials',
        value: jsonEncode(client.credentials.toJson()),
      );

      return client;
    } else {
      throw Exception('Platform tidak didukung.');
    }
  }
}
