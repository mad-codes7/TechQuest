import 'package:flutter/material.dart';
import '../models/furniture_item.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import 'ar_view_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final FavoritesService favoritesService;
  const ProfileScreen({super.key, required this.favoritesService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  Map<String, String> _user = {};
  bool _loading = true;
  bool _updatingLocation = false;
  late AnimationController _ringController;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _ringAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    if (mounted) setState(() { _user = user; _loading = false; });
  }

  Future<void> _updateLocation() async {
    setState(() => _updatingLocation = true);
    final location = await LocationService().fetchCurrentLocation();
    if (location != null) {
      await _authService.updateLocation(location);
      await _loadUser();
    }
    if (mounted) setState(() => _updatingLocation = false);
  }

  String get _initials {
    final name = _user['name'] ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String get _memberSince {
    final raw = _user['joinedDate'] ?? '';
    if (raw.isEmpty) return 'Member';
    try {
      final dt = DateTime.parse(raw);
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return 'Member since ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return 'Member';
    }
  }

  List<FurnitureItem> get _wishlistItems => FurnitureItem.items
      .where((i) => widget.favoritesService.isFavorite(i.name))
      .toList();

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2C1810))),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Color(0xFF7D6B5E))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E8678)))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen(favoritesService: widget.favoritesService)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7F2),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC97B4B))),
      );
    }

    final wishlist = _wishlistItems;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: CustomScrollView(
        slivers: [
          // ── Earthy Header with Avatar ──
          SliverToBoxAdapter(child: _buildHeader()),

          // ── Stats Row ──
          SliverToBoxAdapter(child: _buildStats(wishlist.length)),

          // ── Location Card ──
          SliverToBoxAdapter(child: _buildLocationCard()),

          // ── Wishlist Preview Strip ──
          if (wishlist.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionLabel('Recently Wishlisted', Icons.favorite_rounded)),
            SliverToBoxAdapter(child: _buildWishlistStrip(wishlist)),
          ],

          // ── Account Settings ──
          SliverToBoxAdapter(child: _buildSectionLabel('Account', Icons.person_outline_rounded)),
          SliverToBoxAdapter(child: _buildAccountCard()),

          // ── App Settings ──
          SliverToBoxAdapter(child: _buildSectionLabel('App', Icons.settings_outlined)),
          SliverToBoxAdapter(child: _buildAppCard()),

          // ── Logout ──
          SliverToBoxAdapter(child: _buildLogout()),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC97B4B), Color(0xFF8B5033)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 52),
            child: Column(
              children: [
                // Decorative circles
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing ring
                    AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (_, __) => Transform.scale(
                        scale: _ringAnim.value,
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Inner cream ring
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFAF7F2), width: 3),
                      ),
                    ),
                    // Avatar
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8C4A8), Color(0xFFC97B4B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Name
                Text(
                  _user['name'] ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user['email'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                // Member badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _memberSince,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────
  Widget _buildStats(int wishlistCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _StatTile(value: '$wishlistCount', label: 'Wishlist',
              icon: Icons.favorite_rounded, color: const Color(0xFFEF4444)),
          const SizedBox(width: 12),
          _StatTile(value: '${FurnitureCategory.values.length}', label: 'Categories',
              icon: Icons.grid_view_rounded, color: const Color(0xFFC97B4B)),
          const SizedBox(width: 12),
          _StatTile(value: '${FurnitureItem.items.length}', label: 'Products',
              icon: Icons.inventory_2_rounded, color: const Color(0xFF6B7C5C)),
        ],
      ),
    );
  }

  // ── Location Card ──────────────────────────────────────────
  Widget _buildLocationCard() {
    final loc = _user['location'] ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFC97B4B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Color(0xFFC97B4B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Location',
                      style: TextStyle(color: Color(0xFF9E8678),
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    loc.isNotEmpty ? loc : 'Not set',
                    style: const TextStyle(color: Color(0xFF2C1810),
                        fontSize: 14, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _updatingLocation ? null : _updateLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8DF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _updatingLocation
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Color(0xFFC97B4B), strokeWidth: 2))
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.my_location_rounded,
                              color: Color(0xFFC97B4B), size: 14),
                          SizedBox(width: 5),
                          Text('Update',
                              style: TextStyle(color: Color(0xFFC97B4B),
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Wishlist Preview Strip ─────────────────────────────────
  Widget _buildWishlistStrip(List<FurnitureItem> items) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return GestureDetector(
            onTap: () => Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => ARViewScreen(furniture: item))),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  // Color swatch / category indicator
                  Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97B4B),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E8DF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_categoryIcon(item.category),
                                size: 16, color: const Color(0xFFC97B4B)),
                          ),
                          const SizedBox(height: 6),
                          Text(item.name,
                              style: const TextStyle(color: Color(0xFF2C1810),
                                  fontSize: 11, fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('₹${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: Color(0xFFC97B4B),
                                  fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Label ──────────────────────────────────────────
  Widget _buildSectionLabel(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFC97B4B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFFC97B4B)),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(color: Color(0xFF2C1810),
                  fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ── Account Card ───────────────────────────────────────────
  Widget _buildAccountCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SettingsCard(children: [
        _SettingsItem(icon: Icons.person_outline_rounded,
            label: 'Name', value: _user['name'] ?? ''),
        const Divider(height: 1, color: Color(0xFFF0E8DF)),
        _SettingsItem(icon: Icons.email_outlined,
            label: 'Email', value: _user['email'] ?? ''),
      ]),
    );
  }

  // ── App Card ──────────────────────────────────────────────
  Widget _buildAppCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SettingsCard(children: [
        _SettingsItem(icon: Icons.view_in_ar_rounded,
            label: 'AR Mode', value: 'Scene Viewer / WebXR'),
        const Divider(height: 1, color: Color(0xFFF0E8DF)),
        _SettingsItem(icon: Icons.info_outline_rounded,
            label: 'Version', value: '1.0.0'),
      ]),
    );
  }

  // ── Logout ────────────────────────────────────────────────
  Widget _buildLogout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: _logout,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.22)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text('Logout', style: TextStyle(color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(FurnitureCategory cat) {
    switch (cat) {
      case FurnitureCategory.chair: return Icons.chair_rounded;
      case FurnitureCategory.sofa: return Icons.weekend_rounded;
      case FurnitureCategory.table: return Icons.table_restaurant_rounded;
      case FurnitureCategory.desk: return Icons.desk_rounded;
      case FurnitureCategory.lamp: return Icons.lightbulb_rounded;
      case FurnitureCategory.shelf: return Icons.bookmarks_rounded;
      case FurnitureCategory.door: return Icons.door_front_door_rounded;
      case FurnitureCategory.window: return Icons.window_rounded;
      case FurnitureCategory.gate: return Icons.fence_rounded;
    }
  }
}

// ── Wave Clipper ──────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(
        size.width * 0.25, size.height,
        size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 40,
        size.width, size.height - 16);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_) => false;
}

// ── Stat Tile ─────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatTile({required this.value, required this.label,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(height: 7),
            Text(value, style: const TextStyle(color: Color(0xFF2C1810),
                fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFF9E8678),
                fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }
}

// ── Settings Item ─────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SettingsItem({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: const Color(0xFFF0E8DF),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 17, color: const Color(0xFF7D6B5E)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF9E8678),
                  fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Color(0xFF2C1810),
                  fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
