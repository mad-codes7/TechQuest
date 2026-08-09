import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import 'admin_login_screen.dart';

/// OTP verification screen for new admin registration.
class AdminOtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final FavoritesService favoritesService;

  const AdminOtpScreen({
    super.key,
    required this.name,
    required this.email,
    required this.favoritesService,
  });

  @override
  State<AdminOtpScreen> createState() => _AdminOtpScreenState();
}

class _AdminOtpScreenState extends State<AdminOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _resendCooldown = 60;
  Timer? _timer;
  String _errorText = '';
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_resendCooldown == 0) { t.cancel(); return; }
      setState(() => _resendCooldown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) {
      setState(() => _errorText = 'Please enter all 6 digits');
      return;
    }
    setState(() { _loading = true; _errorText = ''; });

    final error = await _auth.verifyOtp(
      email: widget.email,
      token: _otp,
      name: widget.name,
      role: AppRole.admin,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      setState(() => _errorText = error);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      return;
    }

    // Success — go back to admin login
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Admin account verified! Please login.'),
      backgroundColor: Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
    ));
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (_) =>
              AdminLoginScreen(favoritesService: widget.favoritesService)),
      (route) => false,
    );
  }

  Future<void> _resend() async {
    _startCountdown();
    final error = await _auth.resendOtp(widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'OTP resent! Check your email.'),
      backgroundColor: error != null ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
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

              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFFA78BFA), size: 30),
              ),
              const SizedBox(height: 24),
              const Text('Verify Admin Email',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(text: widget.email,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _otpBox(i)),
              ),

              if (_errorText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_errorText,
                      style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13, fontWeight: FontWeight.w500))),
                ]),
              ],
              const SizedBox(height: 32),

              // Verify Button
              GestureDetector(
                onTap: _loading ? null : _verify,
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
                        : const Text('Verify & Activate Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: _resendCooldown > 0
                    ? Text('Resend OTP in ${_resendCooldown}s',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))
                    : GestureDetector(
                        onTap: _resend,
                        child: const Text('Resend OTP',
                            style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.w700, fontSize: 14))),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int i) => SizedBox(
        width: 48, height: 56,
        child: TextFormField(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          decoration: InputDecoration(
            counterText: '',
            filled: true, fillColor: const Color(0xFF1E293B),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
          ),
          onChanged: (val) {
            setState(() => _errorText = '');
            if (val.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
            if (val.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
            if (_otp.length == 6) FocusScope.of(context).unfocus();
          },
        ),
      );
}
