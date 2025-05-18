import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OrderProcessPage extends StatelessWidget {
  const OrderProcessPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Order Process Page\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
