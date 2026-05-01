import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DriverMapScreen extends StatelessWidget {
  const DriverMapScreen({super.key});

  static const LatLng _hebronCenter = LatLng(31.5326, 35.0998);

  static const List<_ParkingZone> _parkingZones = [
    _ParkingZone(
      name: 'منطقة باب الزاوية',
      location: LatLng(31.5326, 35.0998),
      isAvailable: true,
    ),
    _ParkingZone(
      name: 'منطقة عين سارة',
      location: LatLng(31.5299, 35.1027),
      isAvailable: false,
    ),
    _ParkingZone(
      name: 'منطقة البلدية',
      location: LatLng(31.5355, 35.0969),
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Text(
          'الخريطة',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'خريطة أولية توضّح مناطق الوقوف القريبة داخل الخليل.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF5B6472),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 360,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: _hebronCenter,
              initialZoom: 15.2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flut',
              ),
              MarkerLayer(
                markers: _parkingZones
                    .map(
                      (zone) => Marker(
                        point: zone.location,
                        width: 120,
                        height: 72,
                        child: _MapMarker(zone: zone),
                      ),
                    )
                    .toList(),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.zone});

  final _ParkingZone zone;

  @override
  Widget build(BuildContext context) {
    final markerColor =
        zone.isAvailable ? const Color(0xFF0F766E) : const Color(0xFFC8922E);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            zone.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}

class _ParkingZone {
  const _ParkingZone({
    required this.name,
    required this.location,
    required this.isAvailable,
  });

  final String name;
  final LatLng location;
  final bool isAvailable;
}
