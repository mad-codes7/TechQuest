import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import 'otp_screen.dart';
import 'app_shell.dart';

/// ── User Signup Screen (warm amber theme) ─────────────────────────
class SignupScreen extends StatefulWidget {
  final FavoritesService favoritesService;
  const SignupScreen({super.key, required this.favoritesService});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
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
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
      role: AppRole.user,
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
      // Email confirmation OFF — user is already logged in
      await widget.favoritesService.loadFromSupabase();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AppShell(
              favoritesService: widget.favoritesService, isAdmin: false),
        ),
        (route) => false,
      );
    } else {
      // Email confirmation ON — go to OTP screen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OtpScreen(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          favoritesService: widget.favoritesService,
          role: AppRole.user,
        ),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDE5DC)),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3D2B1F), size: 20),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Icon + Title
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFC97B4B), Color(0xFFE09A65)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: const Color(0xFFC97B4B).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  const Text('Create Account',
                      style: TextStyle(color: Color(0xFF2C1810), fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  const Text('Join FrameKart and explore furniture in AR',
                      style: TextStyle(color: Color(0xFF9E8678), fontSize: 15, height: 1.4)),
                  const SizedBox(height: 36),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97B4B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC97B4B).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined, color: Color(0xFFC97B4B), size: 16),
                        const SizedBox(width: 8),
                        const Text('Registering as a Customer (User)',
                            style: TextStyle(color: Color(0xFFC97B4B), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  _label('Full Name'),
                  const SizedBox(height: 8),
                  _field(ctrl: _nameCtrl, hint: 'John Doe', icon: Icons.person_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your name';
                      if (v.trim().length < 2) return 'Name too short';
                      return null;
                    }),
                  const SizedBox(height: 20),

                  _label('Email Address'),
                  const SizedBox(height: 8),
                  _field(ctrl: _emailCtrl, hint: 'you@example.com', icon: Icons.email_outlined,
                    kb: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                      return null;
                    }),
                  const SizedBox(height: 20),

                  _label('Password'),
                  const SizedBox(height: 8),
                  _field(
                    ctrl: _passCtrl, hint: 'Min. 6 characters', icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF9E8678), size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    }),
                  const SizedBox(height: 36),

                  // Send OTP Button
                  GestureDetector(
                    onTap: _loading ? null : _register,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC97B4B),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFFC97B4B).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
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
                          text: 'Already have an account? ',
                          style: TextStyle(color: Color(0xFF7D6B5E), fontSize: 14),
                          children: [TextSpan(text: 'Login', style: TextStyle(color: Color(0xFFC97B4B), fontWeight: FontWeight.w700))],
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
      style: const TextStyle(color: Color(0xFF3D2B1F), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3));

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
        style: const TextStyle(color: Color(0xFF3D2B1F), fontSize: 15),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC4B5AA)),
          prefixIcon: Icon(icon, color: const Color(0xFF9E8678), size: 20),
          suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEDE5DC))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEDE5DC))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFC97B4B), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
        ),
      );
}
