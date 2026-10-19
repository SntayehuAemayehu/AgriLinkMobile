import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  bool _isFarmer = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final role = await ApiService.getRole();
    _isFarmer = role == 'farmer';
    final list = _isFarmer ? await ApiService.farmerOrders() : await ApiService.myOrders();
    if (!mounted) return;
    setState(() { _orders = list; _loading = false; });
  }

  Future<void> _update(int id, Map<String, dynamic> updates) async {
    final ok = await ApiService.updateOrderStatus(id, updates);
    if (ok) _load();
  }

  Future<void> _rate(int orderId) async {
    int stars = 5;
    final commentCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rate this transaction'),
        content: StatefulBuilder(builder: (_, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
            IconButton(icon: Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
              onPressed: () => setSt(() => stars = i + 1)))),
          TextField(controller: commentCtrl, decoration: const InputDecoration(labelText: 'Comment (optional)', border: OutlineInputBorder())),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true) {
      final res = await ApiService.rateOrder(orderId, stars, commentCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['status'] == 201 ? 'Thanks for rating!' : 'Error: ${res['body']}')));
      _load();
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'completed': return Colors.green;
      case 'rejected':
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Scaffold(
      appBar: AppBar(title: Text(_isFarmer ? 'Incoming Orders' : 'My Orders'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(onRefresh: _load,
            child: _orders.isEmpty ? const Center(child: Text('No orders yet'))
              : ListView.builder(padding: const EdgeInsets.all(8), itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    final status = o['status'] ?? 'pending';
                    final payment = o['payment_status'] ?? 'unpaid';
                    
                    return Card(elevation: 2, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(o['product_title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          // FIXED CHIP HERE
                          Chip(label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: _statusColor(status)),
                        ]),
                        const SizedBox(height: 8),
                        Text(_isFarmer ? 'Buyer: ${o['buyer_name']}' : 'Farmer: ${o['farmer_name']}', style: const TextStyle(color: Colors.grey)),
                        Text('Phone: ${_isFarmer ? o['buyer_phone'] : o['farmer_phone']}'),
                        const Divider(),
                        _buildInfo('Quantity', '${o['quantity_kg']} kg'),
                        _buildInfo('Total Price', '${fmt.format(double.tryParse(o['total_price'].toString()) ?? 0)} ETB', isGreen: true),
                        _buildInfo('Payment Status', payment.replaceAll("_", " ").toUpperCase()),
                        const SizedBox(height: 12),
                        
                        if (_isFarmer && status == 'pending') Row(children: [
                          Expanded(child: ElevatedButton(onPressed: () => _update(o['id'], {'status': 'accepted'}), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Accept'))),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton(onPressed: () => _update(o['id'], {'status': 'rejected'}), child: const Text('Reject'))),
                        ]),
                        if (_isFarmer && status == 'accepted' && payment != 'farmer_confirmed')
                          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _update(o['id'], {'payment_status': 'farmer_confirmed'}), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Confirm Payment Received'))),
                        if (_isFarmer && status == 'accepted' && payment == 'farmer_confirmed')
                          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _update(o['id'], {'status': 'completed'}), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Mark as Completed'))),
                        if (!_isFarmer && status == 'accepted' && payment == 'unpaid')
                          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _update(o['id'], {'payment_status': 'buyer_marked_paid'}), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('I Have Sent Payment'))),
                        if (status == 'completed')
                          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _rate(o['id']), icon: const Icon(Icons.star), label: const Text('Rate Transaction'))),
                      ])));
                  })),
    );
  }

  Widget _buildInfo(String label, String value, {bool isGreen = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isGreen ? Colors.green : Colors.black)),
      ],
    ));
  }
}