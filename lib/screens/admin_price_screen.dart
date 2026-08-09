import 'package:flutter/material.dart';
import '../models/furniture_item.dart';
import '../services/admin_price_service.dart';

class AdminPriceScreen extends StatefulWidget {
  const AdminPriceScreen({super.key});
  @override
  State<AdminPriceScreen> createState() => _AdminPriceScreenState();
}

class _AdminPriceScreenState extends State<AdminPriceScreen> {
  static const _primary = Color(0xFFC97B4B);
  static const _bg = Color(0xFFFAF7F2);
  final _service = AdminPriceService.instance;

  // category filter
  FurnitureCategory? _selectedCat;

  List<FurnitureItem> get _filtered => _selectedCat == null
      ? FurnitureItem.items
      : FurnitureItem.items.where((i) => i.category == _selectedCat).toList();

  void _editPrice(FurnitureItem item) {
    final current = _service.getPrice(item.name, item.price);
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF3D2B1F))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Current: Rs ${current.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF9E8678), fontSize: 13)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'New price (Rs)',
              prefixText: 'Rs ',
              filled: true, fillColor: const Color(0xFFFAF7F2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 1.5)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E8678)))),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text.trim());
              if (val == null || val <= 0) { return; }
              await _service.setPrice(item.name, val);
              if (mounted) { setState(() {}); Navigator.pop(context); }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Price updated for ${item.name}'),
                backgroundColor: const Color(0xFF388E3C),
                behavior: SnackBarBehavior.floating,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: _primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.price_change_rounded, color: _primary, size: 20)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Edit Prices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF3D2B1F))),
                Text('Admin only - tap any item to edit', style: TextStyle(fontSize: 12, color: Color(0xFF9E8678))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFFFECE0), borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.admin_panel_settings_rounded, size: 14, color: _primary),
                  SizedBox(width: 5),
                  Text('ADMIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _primary, letterSpacing: 0.5)),
                ])),
            ]),
            const SizedBox(height: 14),
            // Category filter chips
            SizedBox(height: 34, child: ListView(scrollDirection: Axis.horizontal, children: [
              _chip(null, 'All'),
              ...FurnitureCategory.values.map((c) => _chip(c, c.label)),
            ])),
          ]),
        ),

        // Items list
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final item = _filtered[i];
            final price = _service.getPrice(item.name, item.price);
            final isEdited = _service.overrides.containsKey(item.name);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))]),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: _primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
                  child: Icon(item.icon, color: _primary, size: 22)),
                title: Row(children: [
                  Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3D2B1F)))),
                  if (isEdited) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Edited', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF388E3C)))),
                ]),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 2),
                  Text(item.category.label, style: const TextStyle(fontSize: 12, color: Color(0xFF9E8678))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('Rs ${price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _primary)),
                    if (isEdited && item.price != price) ...[
                      const SizedBox(width: 8),
                      Text('Rs ${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E8678), decoration: TextDecoration.lineThrough)),
                    ],
                  ]),
                ]),
                trailing: IconButton(
                  onPressed: () => _editPrice(item),
                  icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.edit_rounded, color: _primary, size: 18)),
                ),
              ),
            );
          },
        )),
      ])),
    );
  }

  Widget _chip(FurnitureCategory? cat, String label) {
    final sel = _selectedCat == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCat = cat),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _primary : const Color(0xFFE8DDD5)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : const Color(0xFF7A6358))),
      ),
    );
  }
}