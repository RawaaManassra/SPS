import 'package:flutter/material.dart';

import 'package:flut/features/driver/map/driver_map_screen.dart';

class AdminMapScreen extends StatelessWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E3D7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: const SizedBox(
        height: 760,
        child: DriverMapScreen(),
      ),
    );
  }
}
