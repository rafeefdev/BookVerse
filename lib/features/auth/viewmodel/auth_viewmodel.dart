import 'dart:developer';
import 'package:book_verse/core/models/authuser_model.dart';
import 'package:book_verse/features/auth/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Authuser? build() => null;

  Future<void> signInWithGoogle() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.signInWithGoogle();
    if (user != null) {
      state = user;
      log('loggin succesful !:\nusername : ${user.name}\nemail : ${user.email}');
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = null;
  }
}
