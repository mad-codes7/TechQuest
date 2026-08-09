import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import 'app_shell.dart';

class OtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final FavoritesService favoritesService;
  final AppRole role;

  const OtpScreen({
    super.key,
    required this.name,
    required this.email,
    required this.favoritesService,
    this.role = AppRole.user,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  int _resendCooldown = 60;
  Timer? _timer;
  String _errorText = '';
  final _authService = AuthService();

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

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_enteredOtp.length < 6) {
      setState(() => _errorText = 'Please enter all 6 digits');
      return;
    }

    setState(() { _loading = true; _errorText = ''; });

    // Verify OTP with Supabase (real verification)
    final error = await _authService.verifyOtp(
      email: widget.email,
      token: _enteredOtp,
      name: widget.name,
      role: widget.role,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() { _loading = false; _errorText = error; });
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
      return;
    }

    // Fetch location after successful verification
    final location = await LocationService().fetchCurrentLocation();
    if (location != null) {
      await _authService.updateLocation(location);
    }

    // Load wishlist
    await widget.favoritesService.loadFromSupabase();

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AppShell(favoritesService: widget.favoritesService, isAdmin: false)),
      (route) => false,
    );
  }

  Future<void> _resend() async {
    _startCountdown();
    final error = await _authService.resendOtp(widget.email);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('OTP resent! Check your email.'),
        backgroundColor: const Color(0xFF6B7C5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEDE5DC))),
                  child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3D2B1F), size: 20),
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFC97B4B).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFFC97B4B), size: 30),
              ),
              const SizedBox(height: 24),
              const Text('Check your email', style: TextStyle(color: Color(0xFF2C1810), fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF9E8678), fontSize: 14, height: 1.5),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(text: widget.email, style: const TextStyle(color: Color(0xFF3D2B1F), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),

              if (_errorText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_errorText, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w500))),
                ]),
              ],

              const SizedBox(height: 32),

              // Verify button
              GestureDetector(
                onTap: _loading ? null : _verify,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC97B4B),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFFC97B4B).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Verify & Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resend
              Center(
                child: _resendCooldown > 0
                    ? Text('Resend OTP in ${_resendCooldown}s', style: const TextStyle(color: Color(0xFF9E8678), fontSize: 13, fontWeight: FontWeight.w500))
                    : GestureDetector(
                        onTap: _resend,
                        child: const Text('Resend OTP', style: TextStyle(color: Color(0xFFC97B4B), fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48, height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2C1810)),
        decoration: InputDecoration(
          counterText: '',
          filled: true, fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEDE5DC), width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEDE5DC), width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC97B4B), width: 2)),
        ),
        onChanged: (val) {
          setState(() => _errorText = '');
          if (val.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
          if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
          if (_enteredOtp.length == 6) FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
