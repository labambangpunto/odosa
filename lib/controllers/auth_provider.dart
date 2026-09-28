import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/google_auth_service.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<void> login() async {
    final client = await GoogleAuthService.getAuthenticatedClient();
    state = client != null;
  }

  Future<void> logout() async {
    await GoogleAuthService.signOut();
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
