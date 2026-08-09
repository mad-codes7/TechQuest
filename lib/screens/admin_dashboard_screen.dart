import 'package:flutter/material.dart';
import '../models/furniture_item.dart';
import '../services/admin_price_service.dart';
import '../services/reconstruction_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final void Function(int tabIndex)? onSwitchTab;
  const AdminDashboardScreen({super.key, this.onSwitchTab});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── same palette as every other screen ─────────────────────
  static const _bg      = Color(0xFFFAF7F2);
  static const _primary = Color(0xFFC97B4B);
  static const _dark    = Color(0xFF8B5033);
  static const _text    = Color(0xFF2C1810);
  static const _text2   = Color(0xFF3D2B1F);
  static const _muted   = Color(0xFF9E8678);
  static const _chip    = Color(0xFFF0E8DF);

  int  _totalItems   = 0;
  int  _editedPrices = 0;
  int  _models3d     = 0;
  bool _loading      = true;

  late final AnimationController _anim;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _loadStats();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final jobs = await ReconstructionService().getMyJobs();
    if (!mounted) return;
    setState(() {
      _totalItems   = FurnitureItem.items.length;
      _editedPrices = AdminPriceService.instance.overrides.length;
      _models3d     = jobs.length;
      _loading      = false;
    });
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        color: _primary,
        backgroundColor: Colors.white,
        onRefresh: _loadStats,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildSectionLabel('Quick Actions', Icons.bolt_rounded)),
            SliverToBoxAdapter(child: _buildActions()),
            SliverToBoxAdapter(child: _buildSectionLabel('Inventory by Category', Icons.grid_view_rounded)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: _loading
                  ? const SliverToBoxAdapter(
                      child: Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: _primary),
                      )))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildCategoryRow(FurnitureCategory.values[i]),
                        childCount: FurnitureCategory.values.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Gradient header with wave (matches Profile screen) ────────
  Widget _buildHeader() {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_primary, _dark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 52),
            child: Column(children: [
              // Icon badge
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 14),
              const Text('Admin Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('FrameKart Control Panel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13)),
              const SizedBox(height: 12),
              // Live badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, size: 7, color: Color(0xFF81C784)),
                  SizedBox(width: 6),
                  Text('LIVE · Pull to refresh',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Stats row (same white-card style as ProfileScreen._StatTile) ──
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: _loading
          ? Row(children: [
              Expanded(child: _shimmer(80)),
              const SizedBox(width: 12),
              Expanded(child: _shimmer(80)),
              const SizedBox(width: 12),
              Expanded(child: _shimmer(80)),
            ])
          : FadeTransition(
              opacity: _fade,
              child: Row(children: [
                _statTile('Products',     '$_totalItems',   Icons.inventory_2_rounded,  const Color(0xFF4FC3F7)),
                const SizedBox(width: 12),
                _statTile('Prices Edited','$_editedPrices', Icons.price_change_rounded, const Color(0xFF81C784)),
                const SizedBox(width: 12),
                _statTile('3D Models',   '$_models3d',     Icons.view_in_ar_rounded,   _primary),
              ]),
            ),
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(color: _text, fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    ));
  }

  Widget _shimmer(double h) => Container(
    height: h,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
  );

  // ── Section label (matches ProfileScreen._buildSectionLabel) ──
  Widget _buildSectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: _primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800)),
      ]),
    );
  }

  // ── Action tiles ──────────────────────────────────────────────
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          _actionItem(
            icon: Icons.price_change_rounded,
            color: const Color(0xFF81C784),
            title: 'Edit Product Prices',
            subtitle: '$_editedPrices item${_editedPrices == 1 ? '' : 's'} overridden',
            badge: _editedPrices > 0 ? '$_editedPrices' : null,
            onTap: () => widget.onSwitchTab?.call(5),
          ),
          const Divider(height: 1, color: Color(0xFFF0E8DF)),
          _actionItem(
            icon: Icons.view_in_ar_rounded,
            color: _primary,
            title: 'Create 3D Model',
            subtitle: 'Scan any object with AI',
            badge: _models3d > 0 ? '$_models3d models' : null,
            onTap: () => widget.onSwitchTab?.call(4),
          ),
          const Divider(height: 1, color: Color(0xFFF0E8DF)),
          _actionItem(
            icon: Icons.refresh_rounded,
            color: const Color(0xFF4FC3F7),
            title: 'Refresh Stats',
            subtitle: 'Reload dashboard data',
            onTap: _loadStats,
          ),
        ]),
      ),
    );
  }

  Widget _actionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: _text2, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
          ])),
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
            ),
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
        ]),
      ),
    );
  }

  // ── Category breakdown ────────────────────────────────────────
  Widget _buildCategoryRow(FurnitureCategory cat) {
    final count = FurnitureItem.items.where((i) => i.category == cat).length;
    final edited = FurnitureItem.items
        .where((i) => i.category == cat && AdminPriceService.instance.overrides.containsKey(i.name))
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(11)),
          child: Icon(cat.icon, color: _primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(cat.label,
            style: const TextStyle(color: _text2, fontSize: 14, fontWeight: FontWeight.w600))),
        Text('$count items', style: const TextStyle(color: _muted, fontSize: 12)),
        if (edited > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF81C784).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$edited edited',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF388E3C))),
          ),
        ],
      ]),
    );
  }
}

// ── Wave Clipper — exactly the same as ProfileScreen ─────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(size.width * 0.75, size.height - 40, size.width, size.height - 16);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_) => false;
}