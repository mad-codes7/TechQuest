import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import 'login_screen.dart';
import 'admin_login_screen.dart';

/// First screen after onboarding — pick User or Admin role.
class RoleSelectorScreen extends StatefulWidget {
  final FavoritesService favoritesService;
  const RoleSelectorScreen({super.key, required this.favoritesService});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _goTo(Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 380),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0A08), Color(0xFF1F1208), Color(0xFF0D0A08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Brand ────────────────────────────────────
                    _Logo(),
                    const SizedBox(height: 20),
                    const Text(
                      'FrameKart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AR Furniture Experience',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // ── User Card ─────────────────────────────────
                    _RoleCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC97B4B), Color(0xFFE09A65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      glowColor: const Color(0xFFC97B4B),
                      icon: Icons.shopping_bag_rounded,
                      title: 'Continue as User',
                      subtitle: 'Browse furniture, view in AR\nand place orders',
                      badge: 'CUSTOMER',
                      badgeColor: const Color(0xFFFFD580),
                      onTap: () => _goTo(LoginScreen(favoritesService: widget.favoritesService)),
                    ),
                    const SizedBox(height: 18),

                    // ── Admin Card ────────────────────────────────
                    _RoleCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF2D3E55)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      glowColor: const Color(0xFF3B82F6),
                      borderColor: const Color(0xFF334155),
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Continue as Admin',
                      subtitle: 'Manage products, prices\nand 3D reconstruction',
                      badge: 'ADMIN',
                      badgeColor: const Color(0xFF93C5FD),
                      onTap: () => _goTo(AdminLoginScreen(favoritesService: widget.favoritesService)),
                    ),

                    const SizedBox(height: 56),
                    Text(
                      'FrameKart v1.1  ·  Secure Login',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.18),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated Logo ────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 84, height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC97B4B), Color(0xFFE8A068)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC97B4B).withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 40),
      );
}

// ── Role Card ────────────────────────────────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final Gradient gradient;
  final Color glowColor;
  final Color? borderColor;
  final IconData icon;
  final String title, subtitle, badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.gradient,
    required this.glowColor,
    this.borderColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(24),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: _pressed ? 0.5 : 0.25),
                  blurRadius: _pressed ? 28 : 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 58, height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.badgeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: widget.badgeColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(widget.badge,
                                style: TextStyle(
                                    color: widget.badgeColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(widget.subtitle,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                              height: 1.5)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.45), size: 22),
              ],
            ),
          ),
        ),
      );
}
