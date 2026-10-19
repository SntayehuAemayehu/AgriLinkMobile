import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({super.key});
  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _role;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    _role = await ApiService.getRole();
    List<dynamic> list;
    if (_role == 'transporter') {
      list = await ApiService.openTransports();
    } else {
      list = await ApiService.myTransports();
    }
    if (!mounted) return;
    setState(() { _items = list; _loading = false; });
  }

  Future<void> _accept(int id) async {
    final ok = await ApiService.acceptTransport(id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Accepted!')));
      _load();
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'open': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'in_transit': return Colors.purple;
      case 'delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Delivery Jobs'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: _loading ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(onRefresh: _load,
          child: _items.isEmpty ? const Center(child: Text('No transport requests available right now.'))
            : ListView.builder(padding: const EdgeInsets.all(8), itemCount: _items.length, itemBuilder: (_, i) {
              final t = _items[i];
              final status = t['status'] ?? 'open';
              return Card(elevation: 2, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Job #${t['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  // FIXED CHIP HERE
                  Chip(label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: _statusColor(status)),
                ]),
                const Divider(),
                _buildRow(Icons.location_on, 'Pickup', t['pickup_location']),
                _buildRow(Icons.location_off, 'Dropoff', t['dropoff_location']),
                if (t['requester_name'] != null) _buildRow(Icons.person, 'Requested by', t['requester_name']),
                const SizedBox(height: 12),
                if (_role == 'transporter' && status == 'open')
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () => _accept(t['id']), 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Accept Job')
                  )),
              ])));
            })),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
      Icon(icon, size: 18, color: Colors.grey),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Text(value)),
    ]));
  }
}