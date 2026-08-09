import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import 'app_shell.dart';
import 'admin_signup_screen.dart';

/// ── Admin Login Screen (dark slate-blue theme) ────────────────────
class AdminLoginScreen extends StatefulWidget {
  final FavoritesService favoritesService;
  const AdminLoginScreen({super.key, required this.favoritesService});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  final _auth = AuthService();
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error = await _auth.loginWithRole(
      _emailCtrl.text.trim().toLowerCase(),
      _passCtrl.text,
      expectedRole: AppRole.admin,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AppShell(
          favoritesService: widget.favoritesService,
          isAdmin: true,
          adminEmail: _emailCtrl.text.trim().toLowerCase(),
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
                  // Back
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
                      gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.45), blurRadius: 22, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  const Text('Admin Login',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  const Text('Restricted access — verified admins only',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 36),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.security_rounded, color: Color(0xFF60A5FA), size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Your account must be registered\nas Admin to access this portal.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  _label('Admin Email'),
                  const SizedBox(height: 8),
                  _field(ctrl: _emailCtrl, hint: 'admin@framekart.com', icon: Icons.alternate_email_rounded,
                    kb: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter admin email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    }),
                  const SizedBox(height: 20),

                  _label('Password'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _passCtrl, hint: 'Enter your password', icon: Icons.shield_outlined,
                    obscure: _obscure,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B), size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    }),
                  const SizedBox(height: 36),

                  // Login Button
                  GestureDetector(
                    onTap: _loading ? null : _login,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                            begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Access Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Divider
                  Row(children: [
                    const Expanded(child: Divider(color: Color(0xFF1E293B), thickness: 1.5)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
                    const Expanded(child: Divider(color: Color(0xFF1E293B), thickness: 1.5)),
                  ]),
                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AdminSignupScreen(favoritesService: widget.favoritesService))),
                      child: RichText(
                        text: const TextSpan(
                          text: 'New admin? ',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          children: [TextSpan(text: 'Register Admin Account', style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.w700))],
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
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
          errorStyle: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      );
}
