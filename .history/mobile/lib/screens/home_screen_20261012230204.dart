import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import 'add_product_screen.dart';
import 'my_products_screen.dart';
import 'orders_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  bool _loading = true;
  String? _role;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _role = await ApiService.getRole();
    final list = await ApiService.listProducts();
    if (!mounted) return;
    setState(() {
      _products = list;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _orderDialog(int productId, String title, double price) async {
    final qty = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Order: $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Price: ${price.toStringAsFixed(2)} ETB/kg'),
            const SizedBox(height: 10),
            TextField(
              controller: qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );

    if (confirmed == true && qty.text.isNotEmpty) {
      final res = await ApiService.createOrder({
        'product': productId,
        'quantity_kg': qty.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['status'] == 201
                ? 'Order placed successfully!'
                : 'Failed: ${res['body']}',
          ),
        ),
      );
    }
  }

  List<dynamic> get _filtered {
    if (_search.isEmpty) return _products;
    final q = _search.toLowerCase();
    return _products.where((p) {
      return (p['title'] ?? '').toLowerCase().contains(q) ||
          (p['crop_type'] ?? '').toLowerCase().contains(q) ||
          (p['region'] ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final isFarmer = _role == 'farmer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriLink'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Orders',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
          if (isFarmer)
            IconButton(
              icon: const Icon(Icons.inventory),
              tooltip: 'My Products',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                ).then((_) => _load());
              },
            ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: isFarmer
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                ).then((_) => _load());
              },
              icon: const Icon(Icons.add),
              label: const Text('List Produce'),
              backgroundColor: Colors.green,
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by crop, region...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? const Center(child: Text('No products available'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final p = _filtered[i];
                              final isAvailable = p['status'] == 'available';
                              final price =
                                  double.tryParse(
                                    p['price_per_kg'].toString(),
                                  ) ??
                                  0;
                              final total =
                                  double.tryParse(
                                    p['quantity_kg'].toString(),
                                  ) ??
                                  0;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const CircleAvatar(
                                            backgroundColor: Color(0xFFE8F5E9),
                                            child: Icon(
                                              Icons.grass,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p['title'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${p['crop_type']} • ${p['region'] ?? ''}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Chip(
                                            label: Text(
                                              isAvailable
                                                  ? 'Available'
                                                  : 'Sold',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                            backgroundColor: isAvailable
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${fmt.format(price)} ETB / kg',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Text(
                                                'Stock: ${fmt.format(total)} kg',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (!isFarmer && isAvailable)
                                            ElevatedButton.icon(
                                              onPressed: () => _orderDialog(
                                                p['id'],
                                                p['title'] ?? '',
                                                price,
                                              ),
                                              icon: const Icon(
                                                Icons.shopping_cart,
                                                size: 18,
                                              ),
                                              label: const Text('Order'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
