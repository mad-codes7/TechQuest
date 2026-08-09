import 'dart:async';
import 'package:flutter/material.dart';
import '../models/furniture_item.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/admin_price_service.dart';
import 'category_products_screen.dart';
import 'ar_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final FavoritesService favoritesService;
  const HomeScreen({super.key, required this.favoritesService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  FurnitureCategory? _selectedCategory;
  String _searchQuery = '';
  String _userName = '';
  final PageController _bannerController = PageController();
  int _bannerPage = 0;
  Timer? _bannerTimer;

  // Hero banner items
  static final List<FurnitureItem> _bannerItems = [
    FurnitureItem.items.firstWhere((i) => i.category == FurnitureCategory.sofa),
    FurnitureItem.items.firstWhere((i) => i.category == FurnitureCategory.chair),
    FurnitureItem.items.firstWhere((i) => i.category == FurnitureCategory.lamp),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_bannerPage + 1) % _bannerItems.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getUser();
    if (mounted) setState(() => _userName = user['name'] ?? '');
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<FurnitureItem> get _filteredItems {
    return FurnitureItem.items.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<FurnitureItem> _sectionItems(List<FurnitureCategory> cats, {int limit = 6}) {
    return FurnitureItem.items
        .where((i) => cats.contains(i.category))
        .take(limit)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final isFiltering = _selectedCategory != null || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: CustomScrollView(
        slivers: [
          // ── Greeting Header ──
          SliverToBoxAdapter(child: _buildGreetingHeader()),

          // ── Search Bar ──
          SliverToBoxAdapter(child: _buildSearchBar()),

          if (!isFiltering) ...[
            // ── Hero Banner ──
            SliverToBoxAdapter(child: _buildHeroBanner()),

            // ── Category chips ──
            SliverToBoxAdapter(child: _buildCategoryChips()),

            // ── Section: Seating ──
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Seating',
                icon: Icons.chair_rounded,
                onSeeAll: () => _setCategory(FurnitureCategory.chair),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalRow(
                _sectionItems([FurnitureCategory.chair, FurnitureCategory.sofa]),
              ),
            ),

            // ── Section: Lighting ──
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Lighting & Lamps',
                icon: Icons.lightbulb_rounded,
                onSeeAll: () => _setCategory(FurnitureCategory.lamp),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalRow(
                _sectionItems([FurnitureCategory.lamp, FurnitureCategory.gate]),
              ),
            ),

            // ── Section: All Products (magazine grid) ──
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'All Products',
                icon: Icons.grid_view_rounded,
                showSeeAll: false,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: _buildMagazineGrid(FurnitureItem.items),
            ),
          ] else ...[
            // ── Category chips (shown when filtering) ──
            SliverToBoxAdapter(child: _buildCategoryChips()),

            // ── Filtered magazine grid ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: _buildMagazineGrid(filtered),
            ),
          ],
        ],
      ),
    );
  }

  void _setCategory(FurnitureCategory cat) {
    setState(() {
      _selectedCategory = _selectedCategory == cat ? null : cat;
    });
  }

  // ─────────────────────── Widgets ───────────────────────

  Widget _buildGreetingHeader() {
    final firstName = _userName.split(' ').first;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting${firstName.isNotEmpty ? ', $firstName' : ''} 👋',
                  style: const TextStyle(
                    color: Color(0xFF2C1810),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'What are you looking for today?',
                  style: TextStyle(
                    color: Color(0xFF9E8678),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // App icon badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFC97B4B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.view_in_ar_rounded,
                color: Color(0xFFC97B4B), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Color(0xFF3D2B1F), fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search furniture...',
          hintStyle: const TextStyle(color: Color(0xFFC4B5AA), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF9E8678), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                  child: const Icon(Icons.close_rounded,
                      color: Color(0xFF9E8678), size: 18),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF0E8DF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _bannerPage = i),
            itemCount: _bannerItems.length,
            itemBuilder: (ctx, i) => _HeroBannerCard(
              item: _bannerItems[i],
              gradients: const [
                [Color(0xFFC97B4B), Color(0xFF8B5033)],
                [Color(0xFF7D6B5E), Color(0xFF3D2B1F)],
                [Color(0xFF6B7C5C), Color(0xFF3D5244)],
              ],
              gradientIndex: i,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerItems.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _bannerPage == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _bannerPage == i
                    ? const Color(0xFFC97B4B)
                    : const Color(0xFFEDE5DC),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryChip(
            label: 'All',
            icon: Icons.grid_view_rounded,
            selected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...FurnitureCategory.values.map((cat) => _CategoryChip(
                label: cat.label,
                icon: _categoryIcon(cat),
                selected: _selectedCategory == cat,
                onTap: () => setState(() =>
                    _selectedCategory = _selectedCategory == cat ? null : cat),
              )),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    required IconData icon,
    VoidCallback? onSeeAll,
    bool showSeeAll = true,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFC97B4B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFC97B4B)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2C1810),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (showSeeAll && onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See all →',
                style: TextStyle(
                  color: Color(0xFFC97B4B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalRow(List<FurnitureItem> items) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          return SizedBox(
            width: 155,
            child: FurnitureCard(
              item: items[i],
              favoritesService: widget.favoritesService,
            ),
          );
        },
      ),
    );
  }

  SliverList _buildMagazineGrid(List<FurnitureItem> items) {
    final rows = <Widget>[];
    int i = 0;
    while (i < items.length) {
      if (i % 3 == 0) {
        // Full-width card
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 260,
            child: FurnitureCard(
              item: items[i],
              favoritesService: widget.favoritesService,
            ),
          ),
        ));
        i++;
      } else {
        // Two side-by-side cards
        final right = i + 1 < items.length ? items[i + 1] : null;
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 240,
                  child: FurnitureCard(
                    item: items[i],
                    favoritesService: widget.favoritesService,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: right != null
                    ? SizedBox(
                        height: 240,
                        child: FurnitureCard(
                          item: right,
                          favoritesService: widget.favoritesService,
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ));
        i += 2;
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate(rows),
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

// ── Hero Banner Card ──
class _HeroBannerCard extends StatelessWidget {
  final FurnitureItem item;
  final List<List<Color>> gradients;
  final int gradientIndex;

  const _HeroBannerCard({
    required this.item,
    required this.gradients,
    required this.gradientIndex,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = gradients[gradientIndex % gradients.length];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ARViewScreen(furniture: item)),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.category.label.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(builder: (ctx) {
                          final displayPrice = AdminPriceService.instance.getPrice(item.name, item.price);
                          return Text(
                            '₹${displayPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                      ],
                    ),
                    // AR CTA button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar_rounded,
                              color: gradient[0], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'View in Your Room',
                            style: TextStyle(
                              color: gradient[0],
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Chip ──
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC97B4B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFFC97B4B)
                : const Color(0xFFEDE5DC),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC97B4B).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : const Color(0xFF9E8678)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF7D6B5E),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
