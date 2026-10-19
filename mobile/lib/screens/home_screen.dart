import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'add_product_screen.dart';
import 'my_products_screen.dart';
import 'orders_screen.dart';
import 'price_alerts_screen.dart';
import 'logistics_screen.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _role;
  bool _isAdmin = false;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    _role = await ApiService.getRole();
    
    final profileRes = await ApiService.getProfile();
    if (profileRes['status'] == 200) {
      final user = profileRes['body'];
      if (user['role'] == 'admin' || user['is_superuser'] == true) {
        _isAdmin = true;
      }
    }
    
    if (!mounted) return;
    setState(() => _loadingRole = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_isAdmin) {
      return const AdminDashboardScreen();
    }

    List<Widget> pages = [];
    List<BottomNavigationBarItem> navItems = [];

    if (_role == 'transporter') {
      pages = [
        const LogisticsScreen(),
        const _ProfileTab(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Available Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      pages = [
        const _MarketplaceTab(),
        const OrdersScreen(),
        const PriceAlertsScreen(),
        const _ProfileTab(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Market'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Prices'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green.shade800,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
      ),
    );
  }
}

class _MarketplaceTab extends StatefulWidget {
  const _MarketplaceTab({super.key});
  @override
  State<_MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<_MarketplaceTab> {
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
    _products = await ApiService.listProducts();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<dynamic> get _filteredProducts {
    if (_search.isEmpty) return _products;
    final q = _search.toLowerCase();
    return _products.where((p) =>
      (p['title'] ?? '').toLowerCase().contains(q) ||
      (p['crop_type'] ?? '').toLowerCase().contains(q) ||
      (p['region'] ?? '').toLowerCase().contains(q)).toList();
  }

  Future<void> _orderDialog(int productId, String title, double price) async {
    final qty = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Order: $title'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Price: ${price.toStringAsFixed(2)} ETB/kg', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 10),
          TextField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity (kg)', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Place Order')),
        ],
      ),
    );
    if (confirmed == true && qty.text.isNotEmpty) {
      final res = await ApiService.createOrder({'product': productId, 'quantity_kg': qty.text});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['status'] == 201 ? 'Order placed!' : 'Failed: ${res['body']}'), 
        backgroundColor: res['status'] == 201 ? Colors.green : Colors.red
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final isFarmer = _role == 'farmer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriLink Market'),
        backgroundColor: Colors.green, foregroundColor: Colors.white,
        actions: [
          if (isFarmer) IconButton(icon: const Icon(Icons.inventory), tooltip: 'My Products', onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProductsScreen())).then((_) => _load())),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await ApiService.logout();
            if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }),
        ],
      ),
      floatingActionButton: isFarmer ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())).then((_) => _load()),
        icon: const Icon(Icons.add), label: const Text('Sell Produce'), backgroundColor: Colors.green) : null,
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(hintText: 'Search crops, regions...', prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
        )),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _load,
            child: _filteredProducts.isEmpty ? const Center(child: Text('No products available'))
              : ListView.builder(padding: const EdgeInsets.all(8), itemCount: _filteredProducts.length,
                itemBuilder: (_, i) {
                  final p = _filteredProducts[i];
                  final isAvailable = p['status'] == 'available';
                  final price = double.tryParse(p['price_per_kg'].toString()) ?? 0;
                  final total = double.tryParse(p['quantity_kg'].toString()) ?? 0;
                  final imageUrl = p['image_url'];
                  
                  return Card(elevation: 2, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (imageUrl != null) 
                        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(height: 160, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))),
                      Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(p['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          // FIXED CHIP HERE
                          Chip(label: Text(isAvailable ? 'Available' : 'Sold', style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: isAvailable ? Colors.green : Colors.grey),
                        ]),
                        const SizedBox(height: 4),
                        Text('${p['crop_type']} • ${p['region']}', style: const TextStyle(color: Colors.grey)),
                        const Divider(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${fmt.format(price)} ETB / kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                            Text('Stock: ${fmt.format(total)} kg', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ]),
                          if (!isFarmer && isAvailable)
                            ElevatedButton.icon(onPressed: () => _orderDialog(p['id'], p['title'] ?? '', price),
                              icon: const Icon(Icons.shopping_cart, size: 18), label: const Text('Order'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
                        ]),
                      ]))
                    ]));
                })),
        ),
      ]),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!['status'] != 200) return const Center(child: Text('Error loading profile'));
          
          final p = snapshot.data!['body'];
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60))),
            const SizedBox(height: 20),
            _buildInfoRow('Username', p['username']),
            _buildInfoRow('Phone', p['phone']),
            _buildInfoRow('Role', p['role'].toString().toUpperCase()),
            _buildInfoRow('Region', p['region'] ?? '-'),
            _buildInfoRow('Woreda', p['woreda'] ?? '-'),
            _buildInfoRow('Rating', '${p['average_rating'] ?? 0} ⭐'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await ApiService.logout();
                if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }, 
              icon: const Icon(Icons.logout), 
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12))
            )
          ]);
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    ));
  }
}