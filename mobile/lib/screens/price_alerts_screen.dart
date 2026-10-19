import 'package:flutter/material.dart';

class PriceAlertsScreen extends StatefulWidget {
  const PriceAlertsScreen({super.key});

  @override
  State<PriceAlertsScreen> createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends State<PriceAlertsScreen> {
  final List<Map<String, dynamic>> _prices = [
    {
      'crop': 'Teff',
      'price': 125.00,
      'unit': 'kg',
      'trend': 'up',
    },
    {
      'crop': 'Wheat',
      'price': 85.00,
      'unit': 'kg',
      'trend': 'stable',
    },
    {
      'crop': 'Maize',
      'price': 65.00,
      'unit': 'kg',
      'trend': 'up',
    },
    {
      'crop': 'Barley',
      'price': 75.00,
      'unit': 'kg',
      'trend': 'down',
    },
    {
      'crop': 'Sorghum',
      'price': 70.00,
      'unit': 'kg',
      'trend': 'stable',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prices refreshed'),
            ),
          );
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Market Prices',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Latest agricultural commodity prices',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Today\'s Prices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ..._prices.map(
              (item) => _priceCard(
                crop: item['crop'] as String,
                price: item['price'] as double,
                unit: item['unit'] as String,
                trend: item['trend'] as String,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Market prices may change depending on location, '
                        'quality, supply, demand, and market conditions.',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceCard({
    required String crop,
    required double price,
    required String unit,
    required String trend,
  }) {
    IconData trendIcon;
    Color trendColor;
    String trendText;

    switch (trend) {
      case 'up':
        trendIcon = Icons.arrow_upward;
        trendColor = Colors.green;
        trendText = 'Rising';
        break;

      case 'down':
        trendIcon = Icons.arrow_downward;
        trendColor = Colors.red;
        trendText = 'Falling';
        break;

      default:
        trendIcon = Icons.remove;
        trendColor = Colors.grey;
        trendText = 'Stable';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade50,
          child: const Icon(
            Icons.grass,
            color: Colors.green,
          ),
        ),
        title: Text(
          crop,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              trendIcon,
              size: 14,
              color: trendColor,
            ),
            const SizedBox(width: 4),
            Text(
              trendText,
              style: TextStyle(
                color: trendColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${price.toStringAsFixed(2)} ETB',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/ $unit',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}