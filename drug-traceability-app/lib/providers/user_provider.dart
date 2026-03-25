import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

final roleProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  return user?.role ?? 'public';
});
