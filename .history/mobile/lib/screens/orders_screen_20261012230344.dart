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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final role = await ApiService.getRole();
    _isFarmer = role == 'farmer';
    final list = _isFarmer
        ? await ApiService.farmerOrders()
        : await ApiService.myOrders();
    if (!mounted) return;
    setState(() {
      _orders = list;
      _loading = false;
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    final ok = await ApiService.updateOrderStatus(id, status);
    if (ok) _load();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Scaffold(
      appBar: AppBar(
        title: Text(_isFarmer ? 'Incoming Orders' : 'My Orders'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _orders.isEmpty
                  ? const Center(child: Text('No orders yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _orders.length,
                      itemBuilder: (_, i) {
                        final o = _orders[i];
                        final status = o['status'] ?? 'pending';
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        o['product_title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      backgroundColor: _statusColor(status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isFarmer
                                      ? 'Buyer: ${o['buyer_name'] ?? ''}'
                                      : 'Farmer: ${o['farmer_name'] ?? ''}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Quantity: ${o['quantity_kg']} kg',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  'Total: ${fmt.format(double.tryParse(o['total_price'].toString()) ?? 0)} ETB',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Commission (3%): ${fmt.format(double.tryParse(o['commission'].toString()) ?? 0)} ETB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (o['message'] != null &&
                                    o['message'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Note: ${o['message']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                if (_isFarmer && status == 'pending') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _updateStatus(
                                            o['id'],
                                            'accepted',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(
                                            o['id'],
                                            'rejected',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (_isFarmer && status == 'accepted') ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _updateStatus(o['id'], 'completed'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Mark as Completed'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
