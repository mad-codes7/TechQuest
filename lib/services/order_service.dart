import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/furniture_item.dart';
import 'cart_service.dart';

final _db = Supabase.instance.client;

class OrderService {
  static final OrderService instance = OrderService._();
  OrderService._();

  /// Place all cart items as individual orders in Supabase.
  /// Returns null on success, error string on failure.
  Future<String?> placeOrder(List<CartItem> items) async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return 'You must be logged in to place an order.';

      // Best-effort profile fetch — never block the order on a DB error
      String buyerName  = 'Customer';
      String buyerEmail = user.email ?? '';
      try {
        final profile = await _db
            .from('profiles')
            .select('name, email')
            .eq('id', user.id)
            .maybeSingle();
        if (profile != null) {
          buyerName  = (profile['name']  as String?)?.isNotEmpty == true
              ? profile['name'] as String
              : buyerName;
          buyerEmail = (profile['email'] as String?)?.isNotEmpty == true
              ? profile['email'] as String
              : buyerEmail;
        }
      } catch (_) {
        // profiles lookup failed — use Supabase auth email as fallback
      }

      final rows = items.map((cartItem) {
        final seller = SellerInfo.forCategory(cartItem.furniture.category);
        return {
          'buyer_id':           user.id,
          'buyer_name':         buyerName,
          'buyer_email':        buyerEmail,
          'product_name':       cartItem.furniture.name,
          'product_category':   cartItem.furniture.category.name,
          'quantity':           cartItem.quantity,
          'unit_price':         cartItem.furniture.price,
          'total_price':        cartItem.total,
          'seller_email':       seller.email,
          'seller_name':        seller.name,
          'status':             'pending',
        };
      }).toList();

      await _db.from('orders').insert(rows);
      return null;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('relation "orders" does not exist') ||
          msg.contains('42P01') ||
          msg.contains('orders')) {
        return 'Orders system is being set up. Please try again shortly.';
      }
      return 'Could not place order. Please check your connection and try again.';
    }
  }

  /// Fetch orders for a specific seller email (admin view).
  Future<List<Map<String, dynamic>>> fetchOrdersForSeller(String sellerEmail) async {
    try {
      final email = sellerEmail.trim().toLowerCase();
      final rows = await _db
          .from('orders')
          .select()
          .ilike('seller_email', email)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return [];
    }
  }

  /// Update order status (admin action).
  Future<void> updateStatus(int orderId, String status) async {
    await _db
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }

  /// Fetch orders placed by the current user.
  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return [];
      final rows = await _db
          .from('orders')
          .select()
          .eq('buyer_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return [];
    }
  }
}
