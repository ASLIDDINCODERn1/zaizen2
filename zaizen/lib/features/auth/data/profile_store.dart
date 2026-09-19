import 'package:flutter/foundation.dart';
import 'package:zaizen/auth/auth_service.dart';

class ProfileStore extends ChangeNotifier {
  ProfileStore() {
    refresh();
    AuthService.instance.authChanges.listen((_) => refresh());
  }

  String name = '';
  String email = '';
  String? avatarUrl;
  bool loading = true;

  Future<void> refresh() async {
    final auth = AuthService.instance;
    name = auth.displayName;
    email = auth.email;
    avatarUrl = auth.avatarUrl;

    final user = auth.currentUser;
    if (user != null) {
      try {
        final row = await auth.client
            .from('profiles')
            .select('full_name, email, avatar_url')
            .eq('id', user.id)
            .maybeSingle();
        if (row != null) {
          final n = (row['full_name'] as String?)?.trim();
          if (n != null && n.isNotEmpty) name = n;
          final e = (row['email'] as String?)?.trim();
          if (e != null && e.isNotEmpty) email = e;
          final a = (row['avatar_url'] as String?)?.trim();
          if (a != null && a.isNotEmpty) avatarUrl = a;
        }
      } catch (_) {}
    } else {
      name = '';
      email = '';
      avatarUrl = null;
    }
    loading = false;
    notifyListeners();
  }
}
