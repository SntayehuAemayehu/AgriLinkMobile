import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await ApiService.profile();
    if (profile['status'] == 200) {
      _role = profile['body']['role'];
    }
    final list = await ApiService.listProducts();
    setState(() {
      _products = list;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _orderDialog(int productId, String title, double price) async {
    final qty = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Order: $title'),
        content: TextField(
          controller: qty,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity (kg)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Place Order')),
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
        SnackBar(content: Text(res['status'] == 201 ? 'Order placed!' : 'Failed: ${res['body']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriLink'),
        actions: [
          IconButton(icon: const Icon(Icons.list_alt), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }),
          if (_role == 'farmer')
            IconButton(icon: const Icon(Icons.inventory), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProductsScreen()));
            }),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _products.isEmpty
                  ? const Center(child: Text('No products yet'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (_, i) {
                        final p = _products[i];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.grass)),
                            title: Text(p['title']),
                            subtitle: Text(
                              '${p['crop_type']} • ${p['quantity_kg']} kg • ${p['price_per_kg