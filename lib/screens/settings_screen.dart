import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class SettingsScreen extends StatelessWidget {
  final FavoritesService favoritesService;
  const SettingsScreen({super.key, required this.favoritesService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF0D1117),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B2838),
                      Color(0xFF141D26),
                      Color(0xFF0D1117),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // About section
                  _buildSectionLabel('About'),
                  const SizedBox(height: 12),
                  _buildTile(
                    icon: Icons.info_outline_rounded,
                    color: const Color(0xFF6C63FF),
                    title: 'App Version',
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTile(
                    icon: Icons.view_in_ar_rounded,
                    color: const Color(0xFF43B581),
                    title: 'AR Furniture',
                    subtitle: 'Visualize furniture in your space',
                  ),

                  const SizedBox(height: 28),

                  // Data section
                  _buildSectionLabel('Data'),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: favoritesService,
                    builder: (context, _) {
                      return _buildTile(
                        icon: Icons.favorite_rounded,
                        color: const Color(0xFFE84393),
                        title: 'Clear Favorites',
                        subtitle:
                            '${favoritesService.favorites.length} item${favoritesService.favorites.length == 1 ? '' : 's'} saved',
                        onTap: favoritesService.favorites.isNotEmpty
                            ? () => _showClearDialog(context)
                            : null,
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // How it works
                  _buildSectionLabel('How it works'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.touch_app_rounded,
                    color: const Color(0xFF6C63FF),
                    title: 'Browse & Select',
                    description:
                        'Explore the furniture catalog and tap on any item to view it in 3D.',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.threed_rotation_rounded,
                    color: const Color(0xFFFF6584),
                    title: 'Rotate & Zoom',
                    description:
                        'Drag to rotate the model. Pinch to zoom in and out for details.',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    icon: Icons.camera_rounded,
                    color: const Color(0xFF43B581),
                    title: 'Place in AR',
                    description:
                        'Tap the AR icon to place the furniture in your real room using your camera.',
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.view_in_ar_rounded,
                          size: 28,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Made with ♥ using Flutter',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.2),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear Favorites?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will remove all items from your favorites list.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              favoritesService.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Color(0xFFE84393)),
            ),
          ),
        ],
      ),
    );
  }
}
