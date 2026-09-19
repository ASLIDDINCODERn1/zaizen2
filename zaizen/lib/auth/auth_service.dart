import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zaizen/auth/password_rules.dart';
import 'package:zaizen/l10n/app_strings.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const redirectUrl = 'io.zaizen.app://login-callback/';
  static const mediaBucket = 'zaizen';

  bool _listening = false;

  SupabaseClient get client => _client;
  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get session => _client.auth.currentSession;
  bool get isLoggedIn => session != null;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  String get displayName {
    final user = currentUser;
    if (user == null) return '';
    final meta = user.userMetadata ?? {};
    final name = (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;
    return user.email ?? 'User';
  }

  String get email => currentUser?.email ?? '';

  String? get avatarUrl {
    final user = currentUser;
    if (user == null) return null;
    final meta = user.userMetadata ?? {};
    final fromMeta = meta['avatar_url'] ?? meta['picture'];
    if (fromMeta is String && fromMeta.isNotEmpty) return fromMeta;
    return null;
  }

  void startSessionListener() {
    if (_listening) return;
    _listening = true;
    _client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.userUpdated ||
          event == AuthChangeEvent.tokenRefreshed) {
        try {
          await upsertProfile();
        } catch (_) {}
      }
    });
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final emailErr = PasswordRules.emailError(email);
    if (emailErr != null) throw AuthFailure(emailErr);
    if (password.isEmpty)
      throw AuthFailure(LanguageScope.strings.authEnterPassword);
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      await upsertProfile();
      return res;
    } catch (e) {
      throw AuthFailure(mapAuthError(e));
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final nameErr = PasswordRules.nameError(fullName);
    if (nameErr != null) throw AuthFailure(nameErr);
    final emailErr = PasswordRules.emailError(email);
    if (emailErr != null) throw AuthFailure(emailErr);
    final passErr = PasswordRules.passwordError(password, email: email);
    if (passErr != null) throw AuthFailure(passErr);
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim(), 'name': fullName.trim()},
        emailRedirectTo: redirectUrl,
      );
      if (res.session != null) {
        await upsertProfile(fullName: fullName.trim());
      }
      return res;
    } catch (e) {
      throw AuthFailure(mapAuthError(e));
    }
  }

  Future<void> resetPassword(String email) async {
    final emailErr = PasswordRules.emailError(email);
    if (emailErr != null) throw AuthFailure(emailErr);
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectUrl,
      );
    } catch (e) {
      throw AuthFailure(mapAuthError(e));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final passErr = PasswordRules.passwordError(newPassword, email: email);
    if (passErr != null) throw AuthFailure(passErr);
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw AuthFailure(mapAuthError(e));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      var launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
        queryParams: const {
          'access_type': 'offline',
          'prompt': 'select_account',
        },
      );
      if (!launched) {
        launched = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectUrl,
          authScreenLaunchMode: LaunchMode.externalApplication,
          queryParams: const {
            'access_type': 'offline',
            'prompt': 'select_account',
          },
        );
      }
      if (!launched && session == null) {
        throw AuthFailure(LanguageScope.strings.authGoogleCanceled);
      }
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure(mapAuthError(e));
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> upsertProfile({String? fullName, String? avatar}) async {
    final user = currentUser;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'full_name': fullName ?? displayName,
      'avatar_url': ?avatar,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (data.isNotEmpty) {
      await _client.auth.updateUser(UserAttributes(data: data));
    }
    await upsertProfile(fullName: fullName, avatar: avatarUrl);
  }

  Future<String> uploadAvatar(Uint8List bytes, String fileExt) async {
    final user = currentUser;
    if (user == null) throw AuthFailure(LanguageScope.strings.authNeedLogin);
    if (bytes.isEmpty)
      throw AuthFailure(LanguageScope.strings.authUploadDenied);
    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      throw AuthFailure(LanguageScope.strings.authPhotoTooLarge);
    }
    var ext = fileExt.toLowerCase().replaceAll('.', '').trim();
    if (ext == 'jpeg' || ext == 'heic' || ext == 'heif' || ext.isEmpty)
      ext = 'jpg';
    if (ext != 'png' && ext != 'jpg' && ext != 'webp' && ext != 'gif') {
      ext = 'jpg';
    }
    final mime = {
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'webp': 'image/webp',
      'gif': 'image/gif',
    }[ext]!;
    final path = '${user.id}/avatar.$ext';
    try {
      await _client.storage
          .from(mediaBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: mime,
              cacheControl: '3600',
            ),
          );
    } catch (e) {
      final raw = e.toString().toLowerCase();
      if (raw.contains('row-level security') ||
          raw.contains('unauthorized') ||
          raw.contains('not allowed') ||
          raw.contains('security') ||
          raw.contains('rls') ||
          raw.contains('403') ||
          raw.contains('401')) {
        throw AuthFailure(LanguageScope.strings.authUploadDenied);
      }
      throw AuthFailure(mapAuthError(e));
    }
    final url = _client.storage.from(mediaBucket).getPublicUrl(path);
    final withTs = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    await updateProfile(avatarUrl: withTs);
    return withTs;
  }

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;
    final uid = user.id;
    try {
      await _client.storage.from(mediaBucket).remove([
        '$uid/avatar.png',
        '$uid/avatar.jpg',
        '$uid/avatar.jpeg',
        '$uid/avatar.webp',
        '$uid/avatar.gif',
      ]);
    } catch (_) {}
    try {
      await _client.from('profiles').delete().eq('id', uid);
    } catch (_) {}
    try {
      await _client.rpc('delete_own_account');
    } catch (e) {
      await _client.auth.signOut();
      throw AuthFailure(LanguageScope.strings.authDeleteNeedSql);
    }
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  static String mapAuthError(Object e) {
    final s = LanguageScope.strings;
    final raw = e.toString().toLowerCase();
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials'))
        return s.authInvalidCredentials;
      if (msg.contains('email not confirmed')) return s.authEmailNotConfirmed;
      if (msg.contains('user already registered'))
        return s.authAlreadyRegistered;
      if (msg.contains('password should be at least') ||
          msg.contains('password is known to be weak') ||
          msg.contains('weak password')) {
        return s.authWeakPassword;
      }
      if (msg.contains('unsupported provider') ||
          msg.contains('provider is not enabled') ||
          msg.contains('validation failed')) {
        return s.authGoogleDisabled;
      }
      if (msg.contains('rate limit') || msg.contains('over_email_send_rate')) {
        return s.authRateLimit;
      }
      if (msg.contains('row-level security') || msg.contains('not allowed')) {
        return s.authUploadDenied;
      }
      return e.message;
    }
    if (raw.contains('unsupported provider') ||
        raw.contains('provider is not enabled') ||
        raw.contains('unable to exchange external code')) {
      return s.authGoogleDisabled;
    }
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('failed host')) {
      return s.authNetwork;
    }
    if (raw.contains('row-level security') ||
        raw.contains('unauthorized') ||
        raw.contains('403')) {
      return s.authUploadDenied;
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}

class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => message;
}
