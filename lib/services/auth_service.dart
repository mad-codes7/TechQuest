import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

/// Roles supported in this app.
enum AppRole { user, admin }

class AuthService {
  // ── Sign Up ─────────────────────────────────────────────────────
  /// Signs up a new user.
  /// Returns: null = success (OTP sent OR immediately logged in)
  ///          String = error message
  /// Check [needsOtp] after calling to know which flow to use.
  Future<({String? error, bool needsOtp})> signUpFull({
    required String name,
    required String email,
    required String password,
    AppRole role = AppRole.user,
  }) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role.name},
      );

      if (res.user == null) {
        return (error: 'Sign up failed. Please try again.', needsOtp: false);
      }

      // If session is already active → email confirmation is OFF → no OTP needed
      final sessionActive = res.session != null;

      if (sessionActive) {
        // Write profile immediately
        await _safeUpsertProfile(
          id: res.user!.id,
          name: name,
          email: email,
          role: role.name,
        );
        return (error: null, needsOtp: false);
      }

      // Session null → email confirmation is ON → OTP/link was sent
      return (error: null, needsOtp: true);
    } on AuthException catch (e) {
      return (error: e.message, needsOtp: false);
    } catch (e) {
      return (error: 'Sign up error: $e', needsOtp: false);
    }
  }

  // ── Legacy signUp (used by existing screens) ────────────────────
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    AppRole role = AppRole.user,
  }) async {
    final result = await signUpFull(
        name: name, email: email, password: password, role: role);
    return result.error;
  }

  // ── Verify OTP ──────────────────────────────────────────────────
  /// OTP verified → session active → write profile → done.
  Future<String?> verifyOtp({
    required String email,
    required String token,
    required String name,
    AppRole role = AppRole.user,
  }) async {
    try {
      final res = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      if (res.user == null) return 'Invalid or expired OTP. Please try again.';

      // Profile write — best effort, never blocks login
      await _safeUpsertProfile(
        id: res.user!.id,
        name: name,
        email: email,
        role: role.name,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'OTP error: $e';
    }
  }

  // ── Login with Role Check ───────────────────────────────────────
  Future<String?> loginWithRole(
    String email,
    String password, {
    AppRole? expectedRole,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) return 'Login failed. Please try again.';

      if (expectedRole == null) return null;

      // Check role — all DB errors are non-fatal
      String? dbRole;
      try {
        final profile = await _supabase
            .from('profiles')
            .select('role')
            .eq('id', res.user!.id)
            .maybeSingle();

        if (profile == null) {
          // No profile row — auto-create and let them in
          await _safeUpsertProfile(
            id: res.user!.id,
            name: res.user!.userMetadata?['name'] ?? '',
            email: res.user!.email ?? email,
            role: expectedRole.name,
          );
          return null;
        }

        dbRole = profile['role'] as String?;

        if (dbRole == null || dbRole.isEmpty) {
          // Role not set — set it and let them in
          await _supabase
              .from('profiles')
              .update({'role': expectedRole.name, 'email': email})
              .eq('id', res.user!.id);
          return null;
        }
      } catch (_) {
        // DB error (e.g. column missing) — let them in, don't block auth
        return null;
      }

      // Enforce role
      if (dbRole != expectedRole.name) {
        await _supabase.auth.signOut();
        return expectedRole == AppRole.admin
            ? 'Access denied. This account is not an admin.'
            : 'Access denied. Please use the Admin login instead.';
      }

      return null;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') && msg.contains('credential'))
        return 'Wrong email or password.';
      if (msg.contains('invalid login'))
        return 'Wrong email or password.';
      if (msg.contains('email not confirmed'))
        return 'Please verify your email first. Check your inbox for the OTP.';
      return e.message;
    } catch (e) {
      return 'Login error: $e';
    }
  }

  // ── Legacy login ────────────────────────────────────────────────
  Future<String?> login(String email, String password) =>
      loginWithRole(email, password);

  // ── Role from DB ────────────────────────────────────────────────
  Future<AppRole> getCurrentRole() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return AppRole.user;
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      return (profile?['role'] as String?) == 'admin'
          ? AppRole.admin
          : AppRole.user;
    } catch (_) {
      return AppRole.user;
    }
  }

  // ── Logout ──────────────────────────────────────────────────────
  Future<void> logout() async => _supabase.auth.signOut();

  // ── Profile info ────────────────────────────────────────────────
  Future<Map<String, String>> getUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return {};
      final profile = await _supabase
          .from('profiles')
          .select('name, location, role')
          .eq('id', user.id)
          .maybeSingle();
      return {
        'name': profile?['name'] ?? user.userMetadata?['name'] ?? '',
        'email': user.email ?? '',
        'location': profile?['location'] ?? '',
        'role': profile?['role'] ?? 'user',
        'joinedDate': user.createdAt,
      };
    } catch (_) {
      return {};
    }
  }

  // ── Update location ─────────────────────────────────────────────
  Future<void> updateLocation(String location) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      await _supabase
          .from('profiles')
          .update({'location': location})
          .eq('id', user.id);
    } catch (_) {}
  }

  bool isLoggedIn() => _supabase.auth.currentUser != null;

  // ── Resend OTP ──────────────────────────────────────────────────
  Future<String?> resendOtp(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not resend OTP.';
    }
  }

  // ── Internal: safe profile upsert ───────────────────────────────
  Future<void> _safeUpsertProfile({
    required String id,
    required String name,
    required String email,
    required String role,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'location': '',
      });
    } catch (_) {
      // Silently ignore — DB schema might not be ready yet
    }
  }
}
