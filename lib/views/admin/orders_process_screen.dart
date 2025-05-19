import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OrderProcessPage extends StatelessWidget {
  const OrderProcessPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of Orders to Process',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with your order count
                itemBuilder: (context, index) {
                  // Dummy order data, replace with your order model
                  final Map<String, dynamic> order = {
                    'id': '#ORD00${index + 1}',
                    'customer': 'Customer ${index + 1}',
                    'status': 'Pending',
                    'total': 49.99 + index * 10,
                  };
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey[700],
                        child: Text(
                          order['customer'][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(order['id']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: ${order['customer']}'),
                          Text('Status: ${order['status']}'),
                          Text('Total: \$${order['total'].toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          // Handle actions here
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'process',
                            child: Text('Mark as Processed'),
                          ),
                          const PopupMenuItem(
                            value: 'details',
                            child: Text('View Details'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
