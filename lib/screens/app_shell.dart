import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/favorites_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'scan_3d_screen.dart';
import 'admin_price_screen.dart';
import 'admin_dashboard_screen.dart';
import 'cart_screen.dart';
import 'admin_orders_screen.dart';

class AppShell extends StatefulWidget {
  final FavoritesService favoritesService;
  final bool isAdmin;
  /// The email the admin used to log in — passed directly to guarantee
  /// it matches what was stored as seller_email in orders.
  final String? adminEmail;
  const AppShell(
      {super.key, required this.favoritesService, this.isAdmin = false, this.adminEmail});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  static const _primary  = Color(0xFFC97B4B);
  static const _inactive = Color(0xFF9E8678);

  /// Seller email of the currently logged-in admin (to filter their orders).
  String _sellerEmail = '';

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) _loadSellerEmail();
  }

  Future<void> _loadSellerEmail() async {
    // Prefer the email passed from the login screen (already trimmed+lowercased);
    // fall back to Supabase session email.
    if (widget.adminEmail != null && widget.adminEmail!.isNotEmpty) {
      _sellerEmail = widget.adminEmail!;
      setState(() {});
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    _sellerEmail = (user?.email ?? '').trim().toLowerCase();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ── Screens ──────────────────────────────────────────────────
    final screens = widget.isAdmin
        ? [
            AdminDashboardScreen(
                onSwitchTab: (i) => setState(() => _currentIndex = i)),
            CategoriesScreen(favoritesService: widget.favoritesService),
            FavoritesScreen(favoritesService: widget.favoritesService),
            // Admin Orders — filtered by this admin's email
            AdminOrdersScreen(sellerEmail: _sellerEmail),
            const Scan3DScreen(),
            const AdminPriceScreen(),
            ProfileScreen(favoritesService: widget.favoritesService),
          ]
        : [
            HomeScreen(favoritesService: widget.favoritesService),
            CategoriesScreen(favoritesService: widget.favoritesService),
            FavoritesScreen(favoritesService: widget.favoritesService),
            const CartScreen(),
            ProfileScreen(favoritesService: widget.favoritesService),
          ];

    // ── Nav items ─────────────────────────────────────────────────
    final navItems = widget.isAdmin
        ? [
            (0, Icons.dashboard_rounded,    Icons.dashboard_outlined,      'Dashboard'),
            (1, Icons.grid_view_rounded,    Icons.grid_view_outlined,      'Browse'),
            (2, Icons.favorite_rounded,     Icons.favorite_border_rounded, 'Wishlist'),
            (3, Icons.inbox_rounded,        Icons.inbox_outlined,          'Orders'),
            (4, Icons.view_in_ar_rounded,   Icons.view_in_ar_outlined,     'Create 3D'),
            (5, Icons.price_change_rounded, Icons.price_change_outlined,   'Prices'),
            (6, Icons.person_rounded,       Icons.person_outline_rounded,  'Profile'),
          ]
        : [
            (0, Icons.home_rounded,        Icons.home_outlined,           'Home'),
            (1, Icons.grid_view_rounded,   Icons.grid_view_outlined,      'Browse'),
            (2, Icons.favorite_rounded,    Icons.favorite_border_rounded, 'Wishlist'),
            (3, Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, 'Cart'),
            (4, Icons.person_rounded,      Icons.person_outline_rounded,  'Profile'),
          ];

    return Scaffold(
      body: Stack(children: [
        IndexedStack(index: _currentIndex, children: screens),
        // Admin badge
        if (widget.isAdmin)
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECE0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary.withValues(alpha: 0.4)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.admin_panel_settings_rounded, size: 12, color: _primary),
                SizedBox(width: 4),
                Text('ADMIN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                        letterSpacing: 0.5)),
              ]),
            ),
          ),
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, -3))
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: navItems
                  .map((item) =>
                      _navItem(item.$1, item.$2, item.$3, item.$4))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData active, IconData inactive, String label) {
    final isActive = _currentIndex == index;

    // Cart badge
    final showCartBadge = !widget.isAdmin && label == 'Cart';

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3, width: isActive ? 20 : 0,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Cart badge wrapper
            showCartBadge
                ? AnimatedBuilder(
                    animation: CartService.instance,
                    builder: (_, __) {
                      final count = CartService.instance.totalCount;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(isActive ? active : inactive,
                              color: isActive ? _primary : _inactive, size: 22),
                          if (count > 0)
                            Positioned(
                              top: -4, right: -6,
                              child: Container(
                                width: 16, height: 16,
                                decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text('$count',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                : Icon(isActive ? active : inactive,
                    color: isActive ? _primary : _inactive, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? _primary : _inactive)),
          ]),
        ),
      ),
    );
  }
}