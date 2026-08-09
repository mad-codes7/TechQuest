import 'package:flutter/material.dart';
import '../models/furniture_item.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _placing = false;

  Future<void> _placeOrder() async {
    final cart = CartService.instance;
    if (cart.items.isEmpty) return;

    setState(() => _placing = true);
    final error = await OrderService.instance.placeOrder(cart.items);
    if (!mounted) return;
    setState(() => _placing = false);

    if (error != null) {
      _snack(error, isError: true);
    } else {
      cart.clear();
      _snack('🎉 Order placed! The seller has been notified.', isError: false);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final cart = CartService.instance;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF7F2),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                const Text('My Cart',
                    style: TextStyle(
                        color: Color(0xFF2C1810),
                        fontWeight: FontWeight.w900,
                        fontSize: 22)),
                const SizedBox(width: 10),
                if (cart.totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97B4B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${cart.totalCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            actions: [
              if (cart.items.isNotEmpty)
                TextButton(
                  onPressed: () {
                    cart.clear();
                    setState(() {});
                  },
                  child: const Text('Clear',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          body: cart.items.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) =>
                            _CartItemTile(item: cart.items[i]),
                      ),
                    ),
                    _buildCheckout(cart),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFC97B4B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 48, color: Color(0xFFC97B4B)),
            ),
            const SizedBox(height: 24),
            const Text('Your cart is empty',
                style: TextStyle(
                    color: Color(0xFF2C1810),
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Browse furniture and add items\nto see them here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9E8678), fontSize: 14, height: 1.5)),
          ],
        ),
      );

  Widget _buildCheckout(CartService cart) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        child: Column(
          children: [
            // Summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${cart.totalCount} item${cart.totalCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: Color(0xFF9E8678),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(
                  '₹${cart.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Color(0xFF2C1810),
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(color: Color(0xFFEDE5DC)),
            const SizedBox(height: 12),

            // Place Order button
            GestureDetector(
              onTap: _placing ? null : _placeOrder,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFC97B4B),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFC97B4B).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Center(
                  child: _placing
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.shopping_bag_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Place Order',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                        ]),
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Cart item tile ────────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final seller = SellerInfo.forCategory(item.furniture.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.furniture.imageUrl,
                width: 72, height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72, height: 72,
                  color: const Color(0xFFF0E8DF),
                  child: const Icon(Icons.chair_rounded,
                      color: Color(0xFFC97B4B), size: 32),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.furniture.name,
                      style: const TextStyle(
                          color: Color(0xFF2C1810),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text('Seller: ${seller.name}',
                      style: const TextStyle(
                          color: Color(0xFF9E8678), fontSize: 12)),
                  const SizedBox(height: 8),

                  // Quantity + price row
                  Row(
                    children: [
                      // Decrement
                      _QtyBtn(
                        icon: Icons.remove_rounded,
                        onTap: () => cart.decrement(item.furniture),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.quantity}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: Color(0xFF2C1810))),
                      ),
                      // Increment
                      _QtyBtn(
                        icon: Icons.add_rounded,
                        onTap: () => cart.increment(item.furniture),
                      ),
                      const Spacer(),
                      Text('₹${item.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFFC97B4B),
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),

            // Remove
            GestureDetector(
              onTap: () => cart.remove(item.furniture),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded,
                    color: Color(0xFFEF4444), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E8DF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFC97B4B)),
        ),
      );
}
