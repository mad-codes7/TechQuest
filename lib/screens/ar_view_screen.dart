import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/furniture_item.dart';
import '../services/cart_service.dart';

class ARViewScreen extends StatefulWidget {
  final FurnitureItem furniture;
  const ARViewScreen({super.key, required this.furniture});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  bool _autoRotate = true;
  WebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    final item = widget.furniture;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Column(
        children: [
          // ── 3D Viewer (takes all space above the bottom card) ──
          Expanded(
            child: Stack(
              children: [
                // Full-area Model Viewer
                Positioned.fill(
                  child: ModelViewer(
                    backgroundColor: const Color(0xFFFAF7F2),
                    src: 'assets/models/${item.modelFileName}',
                    alt: '3D model of ${item.name}',
                    ar: true,
                    arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                    autoRotate: _autoRotate,
                    cameraControls: true,
                    disableZoom: false,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                  ),
                ),

                // Top bar floating over viewer
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back
                        _CircleBtn(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        // Auto-rotate toggle
                        _CircleBtn(
                          icon: _autoRotate
                              ? Icons.sync_rounded
                              : Icons.sync_disabled_rounded,
                          onTap: () =>
                              setState(() => _autoRotate = !_autoRotate),
                          isActive: _autoRotate,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom info card (always visible, never overlapping) ──
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Name + category row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Color(0xFF2C1810),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.category.label,
                                style: const TextStyle(
                                  color: Color(0xFF9E8678),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Text(
                          '\u20B9${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFC97B4B),
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Dimensions chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E8DF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.straighten_rounded,
                              size: 13, color: Color(0xFF7D6B5E)),
                          const SizedBox(width: 6),
                          Text(
                            item.dimensions,
                            style: const TextStyle(
                              color: Color(0xFF7D6B5E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Seller info strip ──
                    _SellerStrip(seller: SellerInfo.forCategory(item.category)),

                    const SizedBox(height: 10),

                    // Action row: Info + Add to Cart + Place in Room
                    Row(
                      children: [
                        // Info button
                        GestureDetector(
                          onTap: () => _showInfoSheet(context, item),
                          child: Container(
                            height: 48, width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E8DF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.info_outline_rounded,
                                color: Color(0xFF475569), size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add to Cart button
                        AnimatedBuilder(
                          animation: CartService.instance,
                          builder: (ctx, _) {
                            final inCart = CartService.instance.contains(item);
                            return GestureDetector(
                              onTap: () {
                                if (inCart) {
                                  CartService.instance.remove(item);
                                } else {
                                  CartService.instance.add(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.name} added to cart!'),
                                      backgroundColor: const Color(0xFF22C55E),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 48, width: 48,
                                decoration: BoxDecoration(
                                  color: inCart
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFF0E8DF),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: inCart ? [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                                      blurRadius: 8, offset: const Offset(0, 3),
                                    )
                                  ] : null,
                                ),
                                child: Icon(
                                  inCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                                  color: inCart ? Colors.white : const Color(0xFF475569),
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        // Place in Room button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _webViewController?.runJavaScript(
                                "document.querySelector('model-viewer').activateAR()",
                              );
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC97B4B),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC97B4B).withValues(alpha: 0.35),
                                    blurRadius: 10, offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.view_in_ar_rounded, color: Colors.white, size: 19),
                                    SizedBox(width: 6),
                                    Text('View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context, FurnitureItem item) {
    final seller = SellerInfo.forCategory(item.category);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE5DC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Description',
              style: TextStyle(
                color: Color(0xFF2C1810),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 20),
            // ── Contact Seller ──
            const Text(
              'Contact Seller',
              style: TextStyle(
                color: Color(0xFF2C1810),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _SellerStrip(seller: seller),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                // Compute exact button width to avoid fractional-pixel overflow
                final btnWidth =
                    ((constraints.maxWidth - 20) / 3).floorToDouble();
                return Row(
                  children: [
                    _ContactBtn(
                      width: btnWidth,
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: const Color(0xFF22C55E),
                      onTap: () => launchUrl(
                          Uri.parse('tel:${seller.phone.replaceAll(' ', '')}')),
                    ),
                    const SizedBox(width: 10),
                    _ContactBtn(
                      width: btnWidth,
                      icon: Icons.email_rounded,
                      label: 'Email',
                      color: const Color(0xFF3B82F6),
                      onTap: () =>
                          launchUrl(Uri.parse('mailto:${seller.email}')),
                    ),
                    const SizedBox(width: 10),
                    _ContactBtn(
                      width: btnWidth,
                      icon: Icons.chat_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => launchUrl(Uri.parse(
                          'https://wa.me/${seller.phone.replaceAll(RegExp(r'[^0-9]'), '')}')),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Seller strip widget ──────────────────────────────────────────────────────
class _SellerStrip extends StatelessWidget {
  final SellerInfo seller;
  const _SellerStrip({required this.seller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8DF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFC97B4B),
            child: Text(
              seller.name.split(' ').map((w) => w[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(
                    color: Color(0xFF2C1810),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 11, color: Color(0xFF9E8678)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      seller.email,
                      style: const TextStyle(
                          color: Color(0xFF9E8678), fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.phone_outlined,
                      size: 11, color: Color(0xFF9E8678)),
                  const SizedBox(width: 4),
                  Text(
                    seller.phone,
                    style: const TextStyle(
                        color: Color(0xFF9E8678), fontSize: 11),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact button ────────────────────────────────────────────────────────────
class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  // Explicit width supplied by LayoutBuilder to prevent fractional-pixel overflow
  final double? width;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            // Use width: 0.5 (hairline) so border does not add to layout size
            border: Border.all(
              color: color.withValues(alpha: 0.30),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating circle button ──
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC97B4B) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF3D2B1F),
          size: 20,
        ),
      ),
    );
  }
}
