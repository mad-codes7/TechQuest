import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/furniture_item.dart';
import '../services/favorites_service.dart';
import 'ar_view_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesService favoritesService;
  const FavoritesScreen({super.key, required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favoritesService,
      builder: (context, _) {
        final favItems = FurnitureItem.items
            .where((item) => favoritesService.isFavorite(item.name))
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFAF7F2),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 110,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Wishlist',
                        style: TextStyle(
                          color: Color(0xFF2C1810),
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      if (favItems.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${favItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (favItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = favItems[index];
                        return _WishlistCard(
                          item: item,
                          onRemove: () =>
                              favoritesService.toggleFavorite(item.name),
                          onViewAR: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ARViewScreen(furniture: item),
                            ),
                          ),
                        );
                      },
                      childCount: favItems.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 44,
              color: const Color(0xFFEF4444).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Wishlist is Empty',
            style: TextStyle(
              color: Color(0xFF3D2B1F),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the ♥ on any product to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9E8678),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final FurnitureItem item;
  final VoidCallback onRemove;
  final VoidCallback onViewAR;

  const _WishlistCard({
    required this.item,
    required this.onRemove,
    required this.onViewAR,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 3D Model (top) ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
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
              ),
              // Remove (heart) button top-right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info + Actions (bottom) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Name, category, price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Color(0xFF3D2B1F),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.category.label,
                        style: const TextStyle(
                          color: Color(0xFF9E8678),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFFC97B4B),
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                // View in Space button
                GestureDetector(
                  onTap: onViewAR,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97B4B),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC97B4B).withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 15),
                        SizedBox(width: 6),
                        Text(
                          'View in Space',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
