import 'package:flutter/foundation.dart';
import '../models/furniture_item.dart';

/// A single item in the user's cart.
class CartItem {
  final FurnitureItem furniture;
  int quantity;

  CartItem({required this.furniture, this.quantity = 1});

  double get total => furniture.price * quantity;
}

/// In-memory cart that notifies listeners on every change.
class CartService extends ChangeNotifier {
  static final CartService instance = CartService._();
  CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice => _items.fold(0, (sum, i) => sum + i.total);

  bool contains(FurnitureItem furniture) =>
      _items.any((i) => i.furniture.name == furniture.name);

  void add(FurnitureItem furniture) {
    final idx = _items.indexWhere((i) => i.furniture.name == furniture.name);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(furniture: furniture));
    }
    notifyListeners();
  }

  void remove(FurnitureItem furniture) {
    _items.removeWhere((i) => i.furniture.name == furniture.name);
    notifyListeners();
  }

  void increment(FurnitureItem furniture) {
    final idx = _items.indexWhere((i) => i.furniture.name == furniture.name);
    if (idx >= 0) { _items[idx].quantity++; notifyListeners(); }
  }

  void decrement(FurnitureItem furniture) {
    final idx = _items.indexWhere((i) => i.furniture.name == furniture.name);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
