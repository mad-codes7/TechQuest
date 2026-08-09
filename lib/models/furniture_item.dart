import 'package:flutter/material.dart';

// ── Admin Seller Accounts ─────────────────────────────────────────────────────
// Admin 1 : Rajan Mehta   | rajan@framekart.com  | Admin@1234
// Admin 2 : Priya Sharma  | priya@framekart.com  | Admin@5678

class SellerInfo {
  final String name;
  final String email;
  final String phone;

  const SellerInfo({
    required this.name,
    required this.email,
    required this.phone,
  });

  /// Lookup seller by category
  static SellerInfo forCategory(FurnitureCategory cat) =>
      _byCat[cat] ?? admin1;

  // Admin 1 — Rajan Mehta — Chairs · Tables · Desks · Lamps
  static const admin1 = SellerInfo(
    name: 'Rajan Mehta',
    email: 'rajan@framekart.com',
    phone: '+91 98765 11111',
  );

  // Admin 2 — Priya Sharma — Sofas · Shelves · Doors · Windows · Gates
  static const admin2 = SellerInfo(
    name: 'Priya Sharma',
    email: 'priya@framekart.com',
    phone: '+91 98765 22222',
  );

  static const Map<FurnitureCategory, SellerInfo> _byCat = {
    FurnitureCategory.chair:  admin1,
    FurnitureCategory.table:  admin1,
    FurnitureCategory.desk:   admin1,
    FurnitureCategory.lamp:   admin1,
    FurnitureCategory.sofa:   admin2,
    FurnitureCategory.shelf:  admin2,
    FurnitureCategory.door:   admin2,
    FurnitureCategory.window: admin2,
    FurnitureCategory.gate:   admin2,
  };
}


enum FurnitureCategory {
  chair,
  door,
  table,
  window,
  desk,
  shelf,
  gate,
  lamp,
  sofa;

  String get label {
    switch (this) {
      case FurnitureCategory.chair: return 'Chairs';
      case FurnitureCategory.door: return 'Doors';
      case FurnitureCategory.table: return 'Tables';
      case FurnitureCategory.window: return 'Windows';
      case FurnitureCategory.desk: return 'Desks';
      case FurnitureCategory.shelf: return 'Storage Shelves';
      case FurnitureCategory.gate: return 'Gates';
      case FurnitureCategory.lamp: return 'Lamps';
      case FurnitureCategory.sofa: return 'Sofas';
    }
  }

  String get singular {
    switch (this) {
      case FurnitureCategory.chair: return 'Chair';
      case FurnitureCategory.door: return 'Door';
      case FurnitureCategory.table: return 'Table';
      case FurnitureCategory.window: return 'Window';
      case FurnitureCategory.desk: return 'Desk';
      case FurnitureCategory.shelf: return 'Shelf';
      case FurnitureCategory.gate: return 'Gate';
      case FurnitureCategory.lamp: return 'Lamp';
      case FurnitureCategory.sofa: return 'Sofa';
    }
  }

  IconData get icon {
    switch (this) {
      case FurnitureCategory.chair: return Icons.chair_rounded;
      case FurnitureCategory.door: return Icons.door_front_door_rounded;
      case FurnitureCategory.table: return Icons.table_restaurant_rounded;
      case FurnitureCategory.window: return Icons.window_rounded;
      case FurnitureCategory.desk: return Icons.desktop_mac_rounded;
      case FurnitureCategory.shelf: return Icons.shelves;
      case FurnitureCategory.gate: return Icons.fence_rounded;
      case FurnitureCategory.lamp: return Icons.light_rounded;
      case FurnitureCategory.sofa: return Icons.weekend_rounded;
    }
  }

  /// Curated Unsplash image for the category tile
  String get categoryImageUrl {
    switch (this) {
      case FurnitureCategory.chair:
        return 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=600&q=80';
      case FurnitureCategory.door:
        return 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80';
      case FurnitureCategory.table:
        return 'https://images.unsplash.com/photo-1549187774-b4e9b0445b41?w=600&q=80';
      case FurnitureCategory.window:
        return 'https://images.unsplash.com/photo-1604578762246-41134e37f9f5?w=600&q=80';
      case FurnitureCategory.desk:
        return 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80';
      case FurnitureCategory.shelf:
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80';
      case FurnitureCategory.gate:
        return 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=600&q=80';
      case FurnitureCategory.lamp:
        return 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600&q=80';
      case FurnitureCategory.sofa:
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80';
    }
  }
}

class FurnitureItem {
  final String name;
  final String modelFileName;
  final IconData icon;
  final String dimensions;
  final String description;
  final Color cardColor;
  final double scale;
  final FurnitureCategory category;
  final double price;
  final String imageUrl;

  const FurnitureItem({
    required this.name,
    required this.modelFileName,
    required this.icon,
    required this.dimensions,
    required this.description,
    required this.cardColor,
    required this.scale,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  String get heroTag => 'furniture_hero_$name';

  static const primaryBlue = Color(0xFFC97B4B);

  static const List<FurnitureItem> items = [
    // ── Chairs ──
    FurnitureItem(
      name: 'Modern Chair',
      modelFileName: 'chair/modern_chair.glb',
      icon: Icons.chair_rounded,
      dimensions: '50 × 50 × 80 cm',
      description: 'Sleek modern chair with clean lines and ergonomic design. Perfect for living rooms and offices.',
      cardColor: primaryBlue,
      scale: 0.5,
      category: FurnitureCategory.chair,
      price: 12999,
      imageUrl: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Gaming Chair',
      modelFileName: 'chair/gaming_chair.glb',
      icon: Icons.chair_rounded,
      dimensions: '70 × 70 × 130 cm',
      description: 'Ergonomic gaming chair with high backrest and lumbar support for long sessions.',
      cardColor: primaryBlue,
      scale: 0.3,
      category: FurnitureCategory.chair,
      price: 24999,
      imageUrl: 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Accent Chair',
      modelFileName: 'chair/accent_chair.glb',
      icon: Icons.chair_rounded,
      dimensions: '60 × 65 × 85 cm',
      description: 'Elegant accent chair upholstered in premium velvet. A bold focal point for any room.',
      cardColor: primaryBlue,
      scale: 0.45,
      category: FurnitureCategory.chair,
      price: 18499,
      imageUrl: 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Lounge Chair',
      modelFileName: 'chair/lounge_chair.glb',
      icon: Icons.chair_rounded,
      dimensions: '80 × 75 × 90 cm',
      description: 'Deeply cushioned lounge chair for ultimate relaxation. A statement piece for any space.',
      cardColor: primaryBlue,
      scale: 0.45,
      category: FurnitureCategory.chair,
      price: 32999,
      imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Wooden Chair',
      modelFileName: 'chair/wooden_chair.glb',
      icon: Icons.chair_rounded,
      dimensions: '45 × 45 × 90 cm',
      description: 'Classic solid wooden chair with a hand-carved backrest. Rustic charm meets durability.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.5,
      category: FurnitureCategory.chair,
      price: 8499,
      imageUrl: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Plastic Chair',
      modelFileName: 'chair/plastic_chair.glb',
      icon: Icons.chair_rounded,
      dimensions: '42 × 42 × 82 cm',
      description: 'Lightweight stackable plastic chair. Weather-resistant, ideal for indoors and outdoors.',
      cardColor: const Color(0xFF64B5F6),
      scale: 0.5,
      category: FurnitureCategory.chair,
      price: 1999,
      imageUrl: 'https://images.unsplash.com/photo-1579656450812-5b1da79c5ccb?w=600&q=80',
    ),

    // ── Doors ──
    FurnitureItem(
      name: 'Solid Wood Door',
      modelFileName: 'door/solid_wood_door.glb',
      icon: Icons.door_front_door_rounded,
      dimensions: '90 × 5 × 210 cm',
      description: 'Premium teak solid wood door with polished brass hardware. Timeless and sturdy.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.25,
      category: FurnitureCategory.door,
      price: 35999,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Glass Panel Door',
      modelFileName: 'door/glass_panel_door.glb',
      icon: Icons.door_front_door_rounded,
      dimensions: '90 × 5 × 210 cm',
      description: 'Frosted glass panel door with aluminium frame. Lets light flow between spaces.',
      cardColor: const Color(0xFF64B5F6),
      scale: 0.25,
      category: FurnitureCategory.door,
      price: 29999,
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&q=80',
    ),

    // ── Tables ──
    FurnitureItem(
      name: 'Coffee Table',
      modelFileName: 'table/coffee_table.glb',
      icon: Icons.table_bar_rounded,
      dimensions: '100 × 60 × 45 cm',
      description: 'Minimalist coffee table with a glass top and walnut wooden legs.',
      cardColor: primaryBlue,
      scale: 0.35,
      category: FurnitureCategory.table,
      price: 8999,
      imageUrl: 'https://images.unsplash.com/photo-1549187774-b4e9b0445b41?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Dining Table',
      modelFileName: 'table/dining_table.glb',
      icon: Icons.table_restaurant_rounded,
      dimensions: '180 × 90 × 76 cm',
      description: 'Solid oak 6-seater dining table. Built to last and crafted for family moments.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.2,
      category: FurnitureCategory.table,
      price: 52999,
      imageUrl: 'https://images.unsplash.com/photo-1617098900591-3f90928e8c54?w=600&q=80',
    ),

    // ── Windows ──
    FurnitureItem(
      name: 'Bay Window',
      modelFileName: 'window/bay_window.glb',
      icon: Icons.window_rounded,
      dimensions: '120 × 10 × 150 cm',
      description: 'Contemporary bay window with double-glazed panels. Maximises natural light.',
      cardColor: const Color(0xFF64B5F6),
      scale: 0.3,
      category: FurnitureCategory.window,
      price: 42000,
      imageUrl: 'https://images.unsplash.com/photo-1604578762246-41134e37f9f5?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Sliding Window',
      modelFileName: 'window/sliding_window.glb',
      icon: Icons.window_rounded,
      dimensions: '150 × 8 × 120 cm',
      description: 'UPVC sliding window with mosquito mesh. Energy-efficient and easy to operate.',
      cardColor: const Color(0xFF64B5F6),
      scale: 0.3,
      category: FurnitureCategory.window,
      price: 18500,
      imageUrl: 'https://images.unsplash.com/photo-1560185127-6ed189bf02f4?w=600&q=80',
    ),

    // ── Desks ──
    FurnitureItem(
      name: 'Standing Desk',
      modelFileName: 'desk/standing_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '140 × 70 × 72–120 cm',
      description: 'Height-adjustable electric standing desk. Sit-stand for better posture and productivity.',
      cardColor: primaryBlue,
      scale: 0.3,
      category: FurnitureCategory.desk,
      price: 38999,
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Study Desk',
      modelFileName: 'desk/study_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '120 × 60 × 75 cm',
      description: 'Clean minimal study desk with cable management. Perfect for home office setups.',
      cardColor: primaryBlue,
      scale: 0.35,
      category: FurnitureCategory.desk,
      price: 14999,
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Computer Desk',
      modelFileName: 'desk/computer_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '120 × 55 × 75 cm',
      description: 'Spacious computer desk with monitor shelf and keyboard tray. Built for productivity.',
      cardColor: primaryBlue,
      scale: 0.35,
      category: FurnitureCategory.desk,
      price: 19999,
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Metal Desk',
      modelFileName: 'desk/metal_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '130 × 65 × 75 cm',
      description: 'Industrial-style metal frame desk. Durable, modern, and great for small spaces.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.35,
      category: FurnitureCategory.desk,
      price: 11999,
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Modern Desk',
      modelFileName: 'desk/modern_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '140 × 60 × 75 cm',
      description: 'Sleek modern desk with floating design. Pairs well with any contemporary interior.',
      cardColor: primaryBlue,
      scale: 0.35,
      category: FurnitureCategory.desk,
      price: 22999,
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Office Desk',
      modelFileName: 'desk/office_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '150 × 70 × 75 cm',
      description: 'Professional office desk with side drawers. Keeps your workspace neat and organised.',
      cardColor: primaryBlue,
      scale: 0.3,
      category: FurnitureCategory.desk,
      price: 27999,
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Wooden Office Desk',
      modelFileName: 'desk/wooden_office_desk.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '160 × 70 × 75 cm',
      description: 'Executive wooden office desk with a warm oak finish. Timeless and commanding.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.28,
      category: FurnitureCategory.desk,
      price: 42999,
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80',
    ),

    // ── Storage Shelves ──
    FurnitureItem(
      name: 'Bookshelf',
      modelFileName: 'shelf/bookshelf.glb',
      icon: Icons.shelves,
      dimensions: '80 × 35 × 180 cm',
      description: 'Spacious bookshelf with 5 tiers, natural pine finish. Ideal for books and decor.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.25,
      category: FurnitureCategory.shelf,
      price: 15999,
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Floating Shelf Set',
      modelFileName: 'shelf/floating_shelf.glb',
      icon: Icons.shelves,
      dimensions: '60 × 20 × 4 cm (each)',
      description: 'Set of 3 wall-mounted floating shelves. Minimalist display storage for any room.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.4,
      category: FurnitureCategory.shelf,
      price: 4999,
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Display Shelf',
      modelFileName: 'shelf/display_shelf.glb',
      icon: Icons.shelves,
      dimensions: '90 × 30 × 120 cm',
      description: 'Open display shelf with geometric compartments. A stylish way to showcase décor.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.3,
      category: FurnitureCategory.shelf,
      price: 11499,
      imageUrl: 'https://images.unsplash.com/photo-1578500351865-d6c3706f46bc?w=600&q=80',
    ),

    // ── Gates ──
    FurnitureItem(
      name: 'Wrought Iron Gate',
      modelFileName: 'gate/wrought_iron_gate.glb',
      icon: Icons.fence_rounded,
      dimensions: '300 × 5 × 180 cm',
      description: 'Ornate wrought iron gate with powder-coat finish. Security meets elegance.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.2,
      category: FurnitureCategory.gate,
      price: 85000,
      imageUrl: 'https://images.unsplash.com/photo-1558618047-f4cf2bf99c87?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Sliding Steel Gate',
      modelFileName: 'gate/sliding_steel_gate.glb',
      icon: Icons.fence_rounded,
      dimensions: '400 × 5 × 180 cm',
      description: 'Motor-ready sliding steel gate. Contemporary design for residential driveways.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.18,
      category: FurnitureCategory.gate,
      price: 120000,
      imageUrl: 'https://images.unsplash.com/photo-1617721665010-c8a9a93c3a53?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Garden Gate',
      modelFileName: 'gate/garden_gate.glb',
      icon: Icons.fence_rounded,
      dimensions: '120 × 4 × 150 cm',
      description: 'Charming wrought iron garden gate with scroll detailing. Perfect for garden entrances.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.25,
      category: FurnitureCategory.gate,
      price: 32000,
      imageUrl: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=600&q=80',
    ),

    // ── Lamps ──
    FurnitureItem(
      name: 'Floor Lamp',
      modelFileName: 'lamp/floor_lamp.glb',
      icon: Icons.light_rounded,
      dimensions: '30 × 30 × 160 cm',
      description: 'Contemporary arc floor lamp with adjustable brightness. Adds warmth to any room.',
      cardColor: const Color(0xFFF59E0B),
      scale: 0.4,
      category: FurnitureCategory.lamp,
      price: 5999,
      imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Pendant Lamp',
      modelFileName: 'lamp/pendant_lamp.glb',
      icon: Icons.light_rounded,
      dimensions: '40 cm Ø × 120 cm drop',
      description: 'Rattan woven pendant lamp that casts beautiful warm patterns on your ceiling.',
      cardColor: const Color(0xFFF59E0B),
      scale: 0.4,
      category: FurnitureCategory.lamp,
      price: 3499,
      imageUrl: 'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Bedside Lamp',
      modelFileName: 'lamp/bedside_lamp.glb',
      icon: Icons.light_rounded,
      dimensions: '20 × 20 × 45 cm',
      description: 'Compact bedside table lamp with a linen shade and warm glow. Perfect for bedrooms.',
      cardColor: const Color(0xFFF59E0B),
      scale: 0.5,
      category: FurnitureCategory.lamp,
      price: 2299,
      imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600&q=80',
    ),

    // ── Sofas ──
    FurnitureItem(
      name: 'Sofa',
      modelFileName: 'sofa/sofa_3seater.glb',
      icon: Icons.weekend_rounded,
      dimensions: '200 × 90 × 85 cm',
      description: 'Plush 3-seater sofa with premium fabric upholstery. Ultimate comfort for your living space.',
      cardColor: primaryBlue,
      scale: 0.2,
      category: FurnitureCategory.sofa,
      price: 45999,
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
    ),
    FurnitureItem(
      name: 'L-Shape Sofa',
      modelFileName: 'sofa/sofa_lshape.glb',
      icon: Icons.weekend_rounded,
      dimensions: '280 × 180 × 85 cm',
      description: 'Luxurious L-shaped sectional sofa with chaise. Transforms any living room.',
      cardColor: primaryBlue,
      scale: 0.15,
      category: FurnitureCategory.sofa,
      price: 89999,
      imageUrl: 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=600&q=80',
    ),

    // ── New Desks ──
    FurnitureItem(
      name: 'Large Office Desk',
      modelFileName: 'desk/office_desk_large.glb',
      icon: Icons.desktop_mac_rounded,
      dimensions: '180 × 80 × 75 cm',
      description: 'Extra-large executive office desk with ample workspace and built-in cable channels.',
      cardColor: primaryBlue,
      scale: 0.25,
      category: FurnitureCategory.desk,
      price: 54999,
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80',
    ),

    // ── New Doors ──
    FurnitureItem(
      name: 'Grey Wooden Door',
      modelFileName: 'door/grey-wooden-door.glb',
      icon: Icons.door_front_door_rounded,
      dimensions: '90 × 5 × 210 cm',
      description: 'Elegant matte grey wooden door with minimalist panel design. Modern and durable.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.25,
      category: FurnitureCategory.door,
      price: 22999,
      imageUrl: 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Purple Wooden Door',
      modelFileName: 'door/purple-wooden-door.glb',
      icon: Icons.door_front_door_rounded,
      dimensions: '90 × 5 × 210 cm',
      description: 'Bold purple-tinted wooden door — a vibrant statement for contemporary interiors.',
      cardColor: const Color(0xFF7B52AB),
      scale: 0.25,
      category: FurnitureCategory.door,
      price: 26499,
      imageUrl: 'https://images.unsplash.com/photo-1572883454114-1cf0031ede2a?w=600&q=80',
    ),
    FurnitureItem(
      name: 'White Wooden Door',
      modelFileName: 'door/white-wooden-door.glb',
      icon: Icons.door_front_door_rounded,
      dimensions: '90 × 5 × 210 cm',
      description: 'Classic white painted wooden door. Clean, bright, and suits any interior style.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.25,
      category: FurnitureCategory.door,
      price: 19999,
      imageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=600&q=80',
    ),

    // ── New Shelves ──
    FurnitureItem(
      name: 'Corner Storage Cabinet',
      modelFileName: 'shelf/cornered_shelf_attached__storage_cabinet.glb',
      icon: Icons.shelves,
      dimensions: '60 × 60 × 180 cm',
      description: 'Space-saving corner shelf with attached storage cabinet. Ideal for living rooms.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.28,
      category: FurnitureCategory.shelf,
      price: 18999,
      imageUrl: 'https://images.unsplash.com/photo-1578500351865-d6c3706f46bc?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Mini Shelves',
      modelFileName: 'shelf/mini-shelves.glb',
      icon: Icons.shelves,
      dimensions: '40 × 15 × 60 cm',
      description: 'Compact wall-mounted mini shelves for small spaces. Perfect for plants and knick-knacks.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.45,
      category: FurnitureCategory.shelf,
      price: 3499,
      imageUrl: 'https://images.unsplash.com/photo-1578500351865-d6c3706f46bc?w=600&q=80',
    ),

    // ── New Sofas ──
    FurnitureItem(
      name: 'Black Sofa',
      modelFileName: 'sofa/black-sofa.glb',
      icon: Icons.weekend_rounded,
      dimensions: '210 × 90 × 85 cm',
      description: 'Sleek black leather 3-seater sofa. Bold, premium, and effortlessly stylish.',
      cardColor: const Color(0xFF3D2B1F),
      scale: 0.18,
      category: FurnitureCategory.sofa,
      price: 64999,
      imageUrl: 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Grey Sofa',
      modelFileName: 'sofa/grey-sofa.glb',
      icon: Icons.weekend_rounded,
      dimensions: '220 × 95 × 85 cm',
      description: 'Modern grey fabric sofa with deep seating. Neutral tone fits any living room palette.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.17,
      category: FurnitureCategory.sofa,
      price: 57999,
      imageUrl: 'https://images.unsplash.com/photo-1631679706909-1844bbd07221?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Modern Sofa',
      modelFileName: 'sofa/modern-sofa.glb',
      icon: Icons.weekend_rounded,
      dimensions: '230 × 100 × 80 cm',
      description: 'Contemporary low-profile modern sofa with clean geometric lines. A designer statement.',
      cardColor: primaryBlue,
      scale: 0.16,
      category: FurnitureCategory.sofa,
      price: 79999,
      imageUrl: 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=600&q=80',
    ),

    // ── New Tables ──
    FurnitureItem(
      name: 'Folding Table',
      modelFileName: 'table/folding_table.glb',
      icon: Icons.table_bar_rounded,
      dimensions: '120 × 60 × 74 cm',
      description: 'Sturdy folding table that sets up in seconds. Great for events, dining, or workspaces.',
      cardColor: primaryBlue,
      scale: 0.3,
      category: FurnitureCategory.table,
      price: 6999,
      imageUrl: 'https://images.unsplash.com/photo-1532372320978-9b4b969d5a1d?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Mahogany Table',
      modelFileName: 'table/mahogany_table.glb',
      icon: Icons.table_restaurant_rounded,
      dimensions: '160 × 80 × 76 cm',
      description: 'Rich mahogany dining table with hand-carved legs. Heirloom quality for refined homes.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.22,
      category: FurnitureCategory.table,
      price: 89999,
      imageUrl: 'https://images.unsplash.com/photo-1617098900591-3f90928e8c54?w=600&q=80',
    ),
    FurnitureItem(
      name: 'Table & Chair Set',
      modelFileName: 'table/old_table_and_chair_set.glb',
      icon: Icons.table_restaurant_rounded,
      dimensions: '120 × 70 × 75 cm (table)',
      description: 'Classic wooden table and 4-chair dining set with a rustic vintage finish.',
      cardColor: const Color(0xFF8B5E3C),
      scale: 0.2,
      category: FurnitureCategory.table,
      price: 42999,
      imageUrl: 'https://images.unsplash.com/photo-1549187774-b4e9b0445b41?w=600&q=80',
    ),

    // ── New Windows ──
    FurnitureItem(
      name: 'Silver Metal Window',
      modelFileName: 'window/silver-metsl-window.glb',
      icon: Icons.window_rounded,
      dimensions: '120 × 10 × 120 cm',
      description: 'Industrial silver aluminium-frame window with double glazing. Modern and weather-proof.',
      cardColor: const Color(0xFF546E7A),
      scale: 0.28,
      category: FurnitureCategory.window,
      price: 24500,
      imageUrl: 'https://images.unsplash.com/photo-1580236782290-ec77f82f9498?w=600&q=80',
    ),
    FurnitureItem(
      name: 'White Metal Window',
      modelFileName: 'window/white-metal-window.glb',
      icon: Icons.window_rounded,
      dimensions: '150 × 10 × 120 cm',
      description: 'White powder-coated metal-frame sliding window. Clean look with excellent ventilation.',
      cardColor: const Color(0xFF64B5F6),
      scale: 0.28,
      category: FurnitureCategory.window,
      price: 21000,
      imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&q=80',
    ),
  ];

  /// Items filtered by category
  static List<FurnitureItem> byCategory(FurnitureCategory cat) =>
      items.where((i) => i.category == cat).toList();
}
