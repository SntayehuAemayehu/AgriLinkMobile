import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AdminStatsTab(),
      const _AdminUsersTab(),
      const _AdminProductsTab(),
      const _AdminSettingsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// --- TAB 1: DASHBOARD STATS ---
class _AdminStatsTab extends StatelessWidget {
  const _AdminStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would fetch these from an API endpoint like /api/admin/stats/
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Platform Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard('Total Users', 'Dynamic', Icons.people, Colors.blue),
            const SizedBox(width: 12),
            _buildStatCard('Products', 'Dynamic', Icons.grass, Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard('Orders', 'Dynamic', Icons.shopping_cart, Colors.orange),
            const SizedBox(width: 12),
            _buildStatCard('Revenue', 'Dynamic', Icons.attach_money, Colors.purple),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.campaign, color: Colors.indigo),
          title: const Text('Send Broadcast SMS'),
          subtitle: const Text('Send an alert to all farmers'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast feature coming soon')));
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB 2: USERS MANAGEMENT (REAL DATA) ---
class _AdminUsersTab extends StatefulWidget {
  const _AdminUsersTab({super.key});
  @override
  State<_AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<_AdminUsersTab> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await ApiService.adminGetAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_users.isEmpty) return const Center(child: Text('No users found.'));

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final u = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: u['role'] == 'admin' ? Colors.indigo : Colors.green,
                child: Icon(u['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
              ),
              title: Text(u['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${u['role'].toString().toUpperCase()} • ${u['phone']}\n${u['region'] ?? 'No region'}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.grey),
                onPressed: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text('User: ${u['username']}'),
                    content: Text('Role: ${u['role']}\nPhone: ${u['phone']}\nWoreda: ${u['woreda'] ?? '-'}\nRating: ${u['average_rating']}'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                  ));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- TAB 3: PRODUCT APPROVALS (REAL DATA) ---
class _AdminProductsTab extends StatefulWidget {
  const _AdminProductsTab({super.key});
  @override
  State<_AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<_AdminProductsTab> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await ApiService.adminGetAllProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return const Center(child: Text('No products found.'));

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.grass, color: Colors.green)),
              title: Text(p['title'] ?? 'Unknown'),
              subtitle: Text('${p['quantity_kg']} kg @ ${fmt.format(double.tryParse(p['price_per_kg'].toString()) ?? 0)} ETB\nFarmer: ${p['farmer_name']}'),
              isThreeLine: true,
              trailing: Chip(
                label: Text(p['status'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: p['status'] == 'available' ? Colors.green : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- TAB 4: SETTINGS ---
class _AdminSettingsTab extends StatelessWidget {
  const _AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Platform Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable SMS Notifications'),
          subtitle: const Text('Send alerts for new orders'),
          value: true,
          activeColor: Colors.indigo,
          onChanged: (val) {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Commission Rate'),
          subtitle: const Text('Currently set to 3%'),
          trailing: const Text('3%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setting updates coming soon')));
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Company Phone Number'),
          subtitle: const Text('+251911234567'),
          trailing: const Icon(Icons.edit),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setting updates coming soon')));
          },
        ),
      ],
    );
  }
}