import 'package:flutter/material.dart';

class DriverVehiclesScreen extends StatelessWidget {
  const DriverVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مركباتي',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة المركبات المرتبطة بحسابك.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const VehicleListCard(
          plateNumber: '24-381-15',
          model: 'Hyundai i20',
          status: 'مركبة مفعلة',
        ),
        const SizedBox(height: 12),
        const VehicleListCard(
          plateNumber: '31-662-08',
          model: 'Kia Picanto',
          status: 'مركبة مفعلة',
        ),
      ],
    );
  }
}

class VehicleListCard extends StatelessWidget {
  const VehicleListCard({
    super.key,
    required this.plateNumber,
    required this.model,
    required this.status,
  });

  final String plateNumber;
  final String model;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F2EF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plateNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}
