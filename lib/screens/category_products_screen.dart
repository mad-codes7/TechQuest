import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/furniture_item.dart';
import '../services/favorites_service.dart';
import '../services/admin_price_service.dart';
import 'ar_view_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final FurnitureCategory category;
  final FavoritesService favoritesService;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    final items = FurnitureItem.byCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: CustomScrollView(
        slivers: [
          // Header with back button
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF3D2B1F)),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                category.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    category.categoryImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFFC97B4B)),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xDD0F172A)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Count chip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97B4B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length} product${items.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Color(0xFFC97B4B),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => FurnitureCard(
                  item: items[index],
                  favoritesService: favoritesService,
                ),
                childCount: items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Shared product card used by HomeScreen and CategoryProductsScreen
class FurnitureCard extends StatelessWidget {
  final FurnitureItem item;
  final FavoritesService favoritesService;

  const FurnitureCard({
    super.key,
    required this.item,
    required this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favoritesService,
      builder: (context, _) {
        final isFav = favoritesService.isFavorite(item.name);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // 3D model viewer
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: IgnorePointer(
                        child: ModelViewer(
                          src: 'assets/models/${item.modelFileName}',
                          backgroundColor: const Color(0xFFFAF7F2),
                          autoRotate: true,
                          disableZoom: true,
                          cameraControls: false,
                          interactionPrompt: InteractionPrompt.none,
                        ),
                      ),
                    ),
                    // Wishlist button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => favoritesService.toggleFavorite(item.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isFav
                                ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.90),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: isFav ? const Color(0xFFEF4444) : const Color(0xFF9E8678),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info + Actions ──
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Color(0xFF3D2B1F),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Builder(builder: (context) {
                            final displayPrice = AdminPriceService.instance.getPrice(item.name, item.price);
                            final isEdited = displayPrice != item.price;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${displayPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFFC97B4B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                if (isEdited)
                                  Text(
                                    '₹${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Color(0xFF9E8678),
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                      // View in your space button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ARViewScreen(furniture: item),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC97B4B),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC97B4B).withValues(alpha: 0.30),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text(
                                'View in Space',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
