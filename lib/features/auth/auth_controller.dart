import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:aroosi_flutter/utils/debug_logger.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

class AuthController extends Notifier<AuthState> {
  late final Stream<fb.User?> _authStateChanges;
  late final AuthRepository _repo;
  static const String _missingProfileError =
      'Please complete your profile before signing in.';

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    // Listen to Firebase session changes
    _authStateChanges = fb.FirebaseAuth.instance.authStateChanges();
    _authStateChanges.listen((user) async {
      logAuth('authStateChanges: user=${user?.uid ?? 'null'}');
      if (user == null) {
        // Firebase session ended, mark unauthenticated
        state = const AuthState(
          isAuthenticated: false,
          loading: false,
          profile: null,
        );
        logAuth('authStateChanges: state -> unauthenticated (user null)');
      } else {
        // Firebase session present, re-bootstrap backend session/profile
        state = state.copyWith(loading: true);
        await _bootstrap();
      }
    });
    // Initial bootstrap
    logAuth('build(): initializing AuthController, kicking off bootstrap');
    _bootstrap();
    return const AuthState(loading: true);
  }

  Future<void> _bootstrap() async {
    logAuth('_bootstrap(): begin');
    final ok = await _repo.me();
    logAuth('_bootstrap(): me() => $ok');
    if (ok) {
      // Extra safety: ensure Firebase reports a current user and that we can
      // obtain a valid ID token. This prevents situations where the backend
      // incorrectly reports an active session while Firebase has no user —
      // which previously caused the router to treat the app as authenticated
      // and redirect immediately to the dashboard.
      try {
        final fbUser = fb.FirebaseAuth.instance.currentUser;
        if (fbUser == null) {
          logAuth(
            '_bootstrap(): Firebase currentUser is null despite me() true -> treating as unauthenticated',
          );
          state = const AuthState(isAuthenticated: false, loading: false);
          return;
        }
        // Attempt to fetch an ID token to validate session. If this fails,
        // treat as unauthenticated.
        try {
          await fbUser.getIdToken();
        } catch (e) {
          logAuth('_bootstrap(): failed to get Firebase idToken -> $e');
          state = const AuthState(isAuthenticated: false, loading: false);
          return;
        }
      } catch (_) {
        state = const AuthState(isAuthenticated: false, loading: false);
        return;
      }
      final json = await _repo.getProfile();
      logAuth(
        '_bootstrap(): getProfile() => ${json == null ? 'null' : 'json'}',
      );
      if (json == null) {
        // Previously we logged the user out if the profile endpoint returned null.
        // This caused unwanted redirects to the welcome/startup screen on transient
        // failures (e.g. race conditions, slow backend, or profile not yet created).
        // Instead, keep the user authenticated with a null profile so the UI can
        // guide them to complete or retry loading their profile.
        await _handleMissingProfile();
        return;
      }
      state = AuthState(
        isAuthenticated: true,
        loading: false,
        profile: UserProfile.fromJson(json),
      );
      logAuth('_bootstrap(): state -> authenticated with profile');
    } else {
      state = const AuthState(isAuthenticated: false, loading: false);
      logAuth('_bootstrap(): state -> unauthenticated');
    }
  }

  Future<void> login(String email, String password) async {
    logAuth('login(): start email=$email');
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signin(email: email, password: password);
      final ok = await _repo.me();
      logAuth('login(): me() => $ok');
      if (ok) {
        // Verify Firebase user/token before trusting backend session.
        final fbUser = fb.FirebaseAuth.instance.currentUser;
        if (fbUser == null) {
          logAuth(
            'login(): backend me() true but Firebase currentUser is null -> unauthenticated',
          );
          state = const AuthState(isAuthenticated: false, loading: false);
          return;
        }
        final json = await _repo.getProfile();
        logAuth('login(): getProfile() => ${json == null ? 'null' : 'json'}');
        if (json == null) {
          // Keep authenticated; surface message so user can complete profile
          await _handleMissingProfile(showMessage: true);
          return;
        }
        state = AuthState(
          isAuthenticated: true,
          loading: false,
          profile: UserProfile.fromJson(json),
        );
        logAuth('login(): state -> authenticated with profile');
      } else {
        state = const AuthState(isAuthenticated: false, loading: false);
        logAuth('login(): state -> unauthenticated (me() false)');
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      logAuth('login(): error ${e.toString()}');
    }
  }

  Future<void> loginWithGoogle() async {
    logAuth('loginWithGoogle(): start');
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signInWithGoogle();
      final ok = await _repo.me();
      logAuth('loginWithGoogle(): me() => $ok');
      if (ok) {
        // Verify Firebase user/token before trusting backend session.
        final fbUser = fb.FirebaseAuth.instance.currentUser;
        if (fbUser == null) {
          logAuth(
            'loginWithGoogle(): backend me() true but Firebase currentUser is null -> unauthenticated',
          );
          state = const AuthState(isAuthenticated: false, loading: false);
          return;
        }
        final json = await _repo.getProfile();
        logAuth(
          'loginWithGoogle(): getProfile() => ${json == null ? 'null' : 'json'}',
        );
        if (json == null) {
          // Keep authenticated; allow profile completion flow
          await _handleMissingProfile(showMessage: true);
          return;
        }
        state = AuthState(
          isAuthenticated: true,
          loading: false,
          profile: UserProfile.fromJson(json),
        );
        logAuth('loginWithGoogle(): state -> authenticated with profile');
      } else {
        state = const AuthState(isAuthenticated: false, loading: false);
        logAuth('loginWithGoogle(): state -> unauthenticated (me() false)');
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      logAuth('loginWithGoogle(): error ${e.toString()}');
    }
  }

  Future<void> signup(String name, String email, String password) async {
    logAuth('signup(): start name=$name email=$email');
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signup(name: name, email: email, password: password);
      // After signup, some backends may not auto-login; attempt me() to detect session
      final ok = await _repo.me();
      logAuth('signup(): me() => $ok');
      if (ok) {
        final json = await _repo.getProfile();
        logAuth('signup(): getProfile() => ${json == null ? 'null' : 'json'}');
        state = AuthState(
          isAuthenticated: true,
          loading: false,
          profile: json == null ? null : UserProfile.fromJson(json),
        );
        logAuth(
          'signup(): state -> authenticated (profile ${json == null ? 'null' : 'present'})',
        );
      } else {
        state = const AuthState(isAuthenticated: false, loading: false);
        logAuth('signup(): state -> unauthenticated (me() false)');
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      logAuth('signup(): error ${e.toString()}');
    }
  }

  Future<void> logout() async {
    logAuth('logout(): start');
    await _repo.logout();
    state = const AuthState(isAuthenticated: false, loading: false);
    logAuth('logout(): state -> unauthenticated');
  }

  /// Refresh only the profile data without triggering full bootstrap logic.
  Future<void> refreshProfileOnly() async {
    if (!state.isAuthenticated) return;
    try {
      final json = await _repo.getProfile();
      logAuth(
        'refreshProfileOnly(): getProfile() => ${json == null ? 'null' : 'json'}',
      );
      if (json != null) {
        state = state.copyWith(profile: UserProfile.fromJson(json));
        logAuth('refreshProfileOnly(): profile updated');
      }
    } catch (_) {
      // swallow; non-fatal refresh
    }
  }

  Future<void> requestPasswordReset(String email) async {
    logAuth('requestPasswordReset(): start email=$email');
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.requestPasswordReset(email);
      state = state.copyWith(loading: false);
      logAuth('requestPasswordReset(): success');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      logAuth('requestPasswordReset(): error ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email, String password) async {
    logAuth('resetPassword(): start email=$email');
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.resetPassword(email, password);
      state = state.copyWith(loading: false);
      logAuth('resetPassword(): success');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      logAuth('resetPassword(): error ${e.toString()}');
    }
  }

  /// Resend the email verification link; returns true if request accepted.
  Future<bool> resendEmailVerification() async {
    logAuth('resendEmailVerification(): start');
    final ok = await _repo.resendEmailVerification();
    logAuth('resendEmailVerification(): ok=$ok');
    return ok;
  }

  /// Refresh the profile and update state; returns whether email is verified now.
  Future<bool> refreshAndCheckEmailVerified() async {
    try {
      final verified = await _repo.refreshEmailVerified();
      // Always refresh profile to update other fields too
      final json = await _repo.getProfile();
      state = state.copyWith(
        profile: json == null ? null : UserProfile.fromJson(json),
      );
      logAuth(
        'refreshAndCheckEmailVerified(): verified=$verified profile=${json == null ? 'null' : 'present'}',
      );
      return verified;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleMissingProfile({bool showMessage = false}) async {
    logAuth('_handleMissingProfile(): showMessage=$showMessage');
    // IMPORTANT: Do NOT logout here. We intentionally keep the authenticated
    // session so that a null / missing profile (whether because the user has
    // not completed setup or due to a transient backend issue) does not eject
    // them back to the startup screen. The UI should detect a null profile and
    // present either a loading/retry state or a profile completion flow.
    state = AuthState(
      isAuthenticated: true,
      loading: false,
      profile: null,
      error: showMessage ? _missingProfileError : null,
    );
    logAuth('_handleMissingProfile(): state -> authenticated (profile null)');
  }

  Future<void> refresh() async {
    logAuth('refresh(): start');
    state = state.copyWith(loading: true, error: null);
    await _bootstrap();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
