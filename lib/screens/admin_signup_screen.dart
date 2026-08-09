import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import 'admin_otp_screen.dart';

/// ── Admin Signup Screen (dark purple theme) ───────────────────────
/// Requires an Admin Secret Code to register.
class AdminSignupScreen extends StatefulWidget {
  final FavoritesService favoritesService;
  const AdminSignupScreen({super.key, required this.favoritesService});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureSecret = true;
  bool _loading = false;
  final _auth = AuthService();
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  // Change this secret in production
  static const _adminSecret = 'FRAMEKART_ADMIN_2024';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _secretCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await _auth.signUpFull(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: AppRole.admin,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error!),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    if (!result.needsOtp) {
      // Immediately registered — sign out and ask to login properly
      await _auth.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Admin account created! Please login.'),
        backgroundColor: Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ));
      Navigator.of(context).pop(); // back to admin login
    } else {
      // OTP needed
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AdminOtpScreen(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          favoritesService: widget.favoritesService,
        ),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Icon
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9F67FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  const Text('Register Admin',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  const Text('Create a new administrator account',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 32),

                  // Warning banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.key_rounded, color: Color(0xFFA78BFA), size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('You need the Admin Secret Code\nprovided by FrameKart management.',
                            style: TextStyle(color: Color(0xFFA78BFA), fontSize: 13, height: 1.5)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // Fields
                  _label('Full Name'),
                  const SizedBox(height: 8),
                  _field(ctrl: _nameCtrl, hint: 'Admin Name', icon: Icons.badge_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your name';
                      if (v.trim().length < 2) return 'Name too short';
                      return null;
                    }),
                  const SizedBox(height: 20),

                  _label('Admin Email'),
                  const SizedBox(height: 8),
                  _field(ctrl: _emailCtrl, hint: 'admin@framekart.com', icon: Icons.alternate_email_rounded,
                    kb: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                      return null;
                    }),
                  const SizedBox(height: 20),

                  _label('Password'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _passCtrl, hint: 'Min. 6 characters', icon: Icons.lock_outline_rounded,
                    obscure: _obscurePass,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscurePass = !_obscurePass),
                      child: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B), size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    }),
                  const SizedBox(height: 20),

                  _label('Admin Secret Code'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _secretCtrl, hint: 'Enter the secret code', icon: Icons.vpn_key_rounded,
                    obscure: _obscureSecret,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscureSecret = !_obscureSecret),
                      child: Icon(_obscureSecret ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B), size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter the secret code';
                      if (v.trim() != _adminSecret) return 'Invalid secret code';
                      return null;
                    }),
                  const SizedBox(height: 36),

                  // Register Button
                  GestureDetector(
                    onTap: _loading ? null : _register,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9F67FA)],
                            begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Create Admin Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already an admin? ',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          children: [TextSpan(text: 'Login', style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.w700))],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3));

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType kb = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: kb,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF334155)),
          prefixIcon: Icon(icon, color: const Color(0xFF475569), size: 20),
          suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
          filled: true, fillColor: const Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF334155))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF334155))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
          errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      );
}
