import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flut/features/driver/map/models/driver_map_data.dart';
import 'package:flut/features/driver/map/services/driver_map_service.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  static const LatLng _hebronCenter = LatLng(31.5326, 35.0998);

  final DriverMapService _mapService = DriverMapService();

  DriverMapData? _mapData;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الخريطة الحية',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'تعرض الجلسات النشطة وحالات القفل الحالية على امتداد المدينة.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MapCountChip(
                    color: const Color(0xFF0F766E),
                    label: 'جلسات نشطة',
                    count: _mapData?.activeSessions.length ?? 0,
                  ),
                  const SizedBox(width: 10),
                  _MapCountChip(
                    color: const Color(0xFFD94841),
                    label: 'مركبات مقفلة',
                    count: _mapData?.clampedVehicles.length ?? 0,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isLoading ? null : _loadMapData,
                    tooltip: 'تحديث',
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                _MapMessageBox(
                  backgroundColor: const Color(0xFFFFF1F0),
                  borderColor: const Color(0xFFF4B5AF),
                  iconColor: const Color(0xFFD94841),
                  icon: Icons.error_outline_rounded,
                  message: _errorMessage!,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildMapBody(),
              ),
              Positioned(
                right: 14,
                left: 14,
                bottom: 14,
                child: _MapLegendCard(isEmpty: _mapData?.isEmpty ?? true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final mapData = _mapData;
    if (mapData == null) {
      return const Center(
        child: Text('تعذر تحميل بيانات الخريطة.'),
      );
    }

    final markers = <Marker>[
      ...mapData.activeSessions.map(_buildActiveSessionMarker),
      ...mapData.clampedVehicles.map(_buildClampedVehicleMarker),
    ];

    return FlutterMap(
      options: const MapOptions(
        initialCenter: _hebronCenter,
        initialZoom: 14.8,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parkpal',
        ),
        MarkerLayer(markers: markers),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  Marker _buildActiveSessionMarker(DriverMapActiveSession session) {
    return Marker(
      point: LatLng(session.lat, session.lng),
      width: 116,
      height: 86,
      child: _MapMarkerBubble(
        title: 'جلسة نشطة',
        subtitle: session.vehicleId > 0 ? 'مركبة #${session.vehicleId}' : null,
        color: const Color(0xFF0F766E),
        icon: Icons.directions_car_filled_rounded,
      ),
    );
  }

  Marker _buildClampedVehicleMarker(DriverMapClampedVehicle vehicle) {
    return Marker(
      point: LatLng(vehicle.lat, vehicle.lng),
      width: 122,
      height: 90,
      child: _MapMarkerBubble(
        title: 'مركبة مقفلة',
        subtitle: vehicle.unregisteredVehicleId > 0
            ? 'معرّف #${vehicle.unregisteredVehicleId}'
            : null,
        color: const Color(0xFFD94841),
        icon: Icons.gpp_bad_rounded,
      ),
    );
  }

  Future<void> _loadMapData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mapData = await _mapService.getMapData();
      if (!mounted) return;
      setState(() {
        _mapData = mapData;
      });
    } on DriverMapException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذر تحميل بيانات الخريطة حالياً.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class _MapCountChip extends StatelessWidget {
  const _MapCountChip({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color,
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MapMessageBox extends StatelessWidget {
  const _MapMessageBox({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.message,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegendCard extends StatelessWidget {
  const _MapLegendCard({
    required this.isEmpty,
  });

  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المؤشرات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _LegendItem(
                color: Color(0xFF0F766E),
                label: 'جلسة وقوف نشطة',
              ),
              _LegendItem(
                color: Color(0xFFD94841),
                label: 'مركبة مقفلة',
              ),
            ],
          ),
          if (isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'لا توجد بيانات مرئية حالياً على الخريطة.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _MapMarkerBubble extends StatelessWidget {
  const _MapMarkerBubble({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String? subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF5B6472),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}
