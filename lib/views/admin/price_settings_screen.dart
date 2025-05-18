import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PriceSettingPage extends StatelessWidget {
  const PriceSettingPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Price Setting Page\n(Coming Soon)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
