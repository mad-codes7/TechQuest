import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/furniture_item.dart';

/// Admin-only screen: shows all orders for this admin's products.
class AdminOrdersScreen extends StatefulWidget {
  final String sellerEmail;
  const AdminOrdersScreen({super.key, required this.sellerEmail});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final orders =
        await OrderService.instance.fetchOrdersForSeller(widget.sellerEmail);
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':   return const Color(0xFFF59E0B);
      case 'confirmed': return const Color(0xFF3B82F6);
      case 'shipped':   return const Color(0xFF8B5CF6);
      case 'delivered': return const Color(0xFF22C55E);
      case 'cancelled': return const Color(0xFFEF4444);
      default:          return const Color(0xFF94A3B8);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':   return Icons.hourglass_empty_rounded;
      case 'confirmed': return Icons.check_circle_outline_rounded;
      case 'shipped':   return Icons.local_shipping_rounded;
      case 'delivered': return Icons.done_all_rounded;
      case 'cancelled': return Icons.cancel_outlined;
      default:          return Icons.info_outline_rounded;
    }
  }

  Future<void> _updateStatus(Map<String, dynamic> order, String newStatus) async {
    await OrderService.instance.updateStatus(order['id'] as int, newStatus);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    // Count pending
    final pending = _orders.where((o) => o['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Incoming Orders',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20)),
            if (pending > 0)
              Text('$pending new order${pending == 1 ? '' : 's'} awaiting',
                  style: const TextStyle(
                      color: Color(0xFFF59E0B), fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : _orders.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF3B82F6),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (ctx, i) => _OrderCard(
                      order: _orders[i],
                      statusColor: _statusColor(_orders[i]['status'] ?? 'pending'),
                      statusIcon: _statusIcon(_orders[i]['status'] ?? 'pending'),
                      onStatusChange: (s) => _updateStatus(_orders[i], s),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_rounded,
                  size: 44, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 20),
            const Text('No orders yet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Orders from users will appear here.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ],
        ),
      );
}

// ── Order Card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final IconData statusIcon;
  final void Function(String) onStatusChange;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.statusIcon,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final status    = order['status'] ?? 'pending';
    final createdAt = order['created_at'] as String? ?? '';
    final dateStr   = createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['product_name'] ?? 'Product',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16),
                      ),
                      Text(
                        '${order['product_category']?.toString().toUpperCase() ?? ''} · $dateStr',
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 14),

            // ── Buyer Info ──
            _row(Icons.person_rounded, 'Buyer',
                '${order['buyer_name']} (${order['buyer_email']})'),
            const SizedBox(height: 6),
            _row(Icons.shopping_bag_rounded, 'Qty',
                '${order['quantity']} unit${(order['quantity'] ?? 1) > 1 ? 's' : ''}'),
            const SizedBox(height: 6),
            _row(Icons.currency_rupee_rounded, 'Total',
                '₹${(order['total_price'] as num?)?.toStringAsFixed(0) ?? '0'}'),
            const SizedBox(height: 14),

            // ── Status Actions (only for pending) ──
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Confirm',
                      color: const Color(0xFF3B82F6),
                      icon: Icons.check_rounded,
                      onTap: () => onStatusChange('confirmed'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Cancel',
                      color: const Color(0xFFEF4444),
                      icon: Icons.close_rounded,
                      onTap: () => onStatusChange('cancelled'),
                    ),
                  ),
                ],
              )
            else if (status == 'confirmed')
              _ActionBtn(
                label: 'Mark as Shipped',
                color: const Color(0xFF8B5CF6),
                icon: Icons.local_shipping_rounded,
                onTap: () => onStatusChange('shipped'),
              )
            else if (status == 'shipped')
              _ActionBtn(
                label: 'Mark as Delivered',
                color: const Color(0xFF22C55E),
                icon: Icons.done_all_rounded,
                onTap: () => onStatusChange('delivered'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text('$label: ',
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ),
        ],
      );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}
