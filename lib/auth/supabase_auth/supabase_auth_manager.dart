import 'dart:async';

import 'package:flutter/material.dart';
import '/auth/auth_manager.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'email_auth.dart';

import 'supabase_user_provider.dart';

export '/auth/base_auth_user_provider.dart';

class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  static const _mobilePasswordResetRedirect =
      'kgpassnew://kgpassnew.com/updatePassword';

  String _passwordResetRedirectUrl() {
    if (isWeb) {
      return Uri.base.resolve('/updatePassword').toString();
    }
    return _mobilePasswordResetRedirect;
  }

  String _authErrorMessage(AuthException e) {
    final message = e.message;
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid login credentials')) {
      return 'Неверная почта или пароль.';
    }
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('already in use')) {
      return 'Эта почта уже зарегистрирована.';
    }
    if (lowerMessage.contains('password') &&
        (lowerMessage.contains('weak') || lowerMessage.contains('short'))) {
      return 'Пароль слишком короткий или простой.';
    }
    if (lowerMessage.contains('email')) {
      return 'Проверьте почту и попробуйте ещё раз.';
    }

    return 'Ошибка авторизации: $message';
  }

  void _showAuthMessage(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Future signOut() {
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      if (!loggedIn) {
        debugPrint('delete user attempted with no logged in user');
        return;
      }
      await currentUser?.delete();
    } on AuthException catch (e) {
      if (!context.mounted) {
        return;
      }
      _showAuthMessage(
        context,
        _authErrorMessage(e),
        backgroundColor: const Color(0xFFFFDADA),
      );
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        debugPrint('update email attempted with no logged in user');
        return;
      }
      await currentUser?.updateEmail(email);
    } on AuthException catch (e) {
      if (!context.mounted) {
        return;
      }
      _showAuthMessage(
        context,
        _authErrorMessage(e),
        backgroundColor: const Color(0xFFFFDADA),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    _showAuthMessage(
      context,
      'Мы отправили письмо для подтверждения новой почты.',
    );
  }

  @override
  Future<bool> updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      if (!loggedIn) {
        debugPrint('update password attempted with no logged in user');
        _showAuthMessage(
          context,
          'Ссылка для сброса пароля устарела. Запросите новую ссылку.',
          backgroundColor: const Color(0xFFFFDADA),
        );
        return false;
      }
      await currentUser?.updatePassword(newPassword);
    } on AuthException catch (e) {
      if (!context.mounted) {
        return false;
      }
      _showAuthMessage(
        context,
        _authErrorMessage(e),
        backgroundColor: const Color(0xFFFFDADA),
      );
      return false;
    }
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    try {
      await SupaFlow.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo ?? _passwordResetRedirectUrl(),
      );
    } on AuthException catch (e) {
      if (!context.mounted) {
        return false;
      }
      _showAuthMessage(
        context,
        _authErrorMessage(e),
        backgroundColor: const Color(0xFFFFDADA),
      );
      return false;
    }
    return true;
  }

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailSignInFunc(email, password),
      );

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) =>
      _signInOrCreateAccount(
        context,
        () => emailCreateAccountFunc(email, password),
      );

  /// Tries to sign in or create an account using Supabase Auth.
  /// Returns the User object if sign in was successful.
  Future<BaseAuthUser?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      final authUser = user == null ? null : KGPassNewSupabaseUser(user);

      // Update currentUser here in case user info needs to be used immediately
      // after a user is signed in. This should be handled by the user stream,
      // but adding here too in case of a race condition where the user stream
      // doesn't assign the currentUser in time.
      if (authUser != null) {
        currentUser = authUser;
        AppStateNotifier.instance.update(authUser);
      }
      return authUser;
    } on AuthException catch (e) {
      if (!context.mounted) {
        return null;
      }
      _showAuthMessage(
        context,
        _authErrorMessage(e),
        backgroundColor: const Color(0xFFFFDADA),
      );
      return null;
    }
  }
}
