import 'package:flutter/material.dart';

import 'package:flut/features/driver/parking/driver_parking_session.dart';
import 'package:flut/features/driver/parking/services/parking_service.dart';
import 'package:flut/features/driver/vehicles/driver_vehicle_form_screen.dart';
import 'package:flut/features/driver/vehicles/models/driver_vehicle.dart';
import 'package:flut/features/driver/vehicles/services/vehicle_service.dart';

class StartParkingScreen extends StatefulWidget {
  const StartParkingScreen({super.key});

  @override
  State<StartParkingScreen> createState() => _StartParkingScreenState();
}

class _StartParkingScreenState extends State<StartParkingScreen> {
  static const _stepTitles = [
    'اختيار المركبة',
    'تأكيد الموقع',
    'اختيار المدة',
    'التأكيد والبدء',
  ];

  static const _fallbackLatitude = 31.5326;
  static const _fallbackLongitude = 35.0998;

  final _vehicleService = VehicleService();
  final _parkingService = ParkingService();
  final _qrController = TextEditingController();

  int _currentStep = 0;
  int _selectedVehicleIndex = 0;
  int _selectedDurationMinutes = 30;
  bool _useCurrentLocation = true;
  bool _isLoadingVehicles = true;
  bool _isSubmitting = false;
  String? _loadError;
  String? _submitError;
  List<DriverVehicle> _vehicles = const [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ابدأ جلسة وقوف'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F3EF),
              Color(0xFFF7F4ED),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text(
                'الخطوة ${_currentStep + 1} من 4',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF0F766E),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _FlowMiniProgress(currentStep: _currentStep),
              const SizedBox(height: 18),
              Text(
                _stepTitles[_currentStep],
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitleForStep(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55606E),
                ),
              ),
              const SizedBox(height: 18),
              if (_submitError != null) ...[
                _ErrorBanner(message: _submitError!),
                const SizedBox(height: 12),
              ],
              _buildStepContent(),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _goNext,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : Text(_currentStep == 3 ? 'تأكيد وبدء الجلسة' : 'متابعة'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSubmitting ? null : _goBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  side: const BorderSide(color: Color(0xFF0F766E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(_currentStep == 0 ? 'إلغاء' : 'رجوع'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleForStep() {
    switch (_currentStep) {
      case 0:
        return 'اختري المركبة التي ستبدئين بها الجلسة. إذا لم تكن موجودة، أضيفيها أولاً.';
      case 1:
        return 'يمكنك استخدام الموقع الحالي أو إدخال رمز QR الخاص بمكان الوقوف. الربط الحالي يرسل موقعاً محفوظاً مؤقتاً إلى الباك.';
      case 2:
        return 'الحد الأدنى 30 دقيقة بسعر 1 شيكل، والسعر يزيد كل نصف ساعة.';
      default:
        return 'الدفع الفعلي في الباك يتم من المحفظة فقط، لذلك راجعي الرصيد والمعلومات قبل البدء.';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVehicleStep();
      case 1:
        return _LocationStep(
          useCurrentLocation: _useCurrentLocation,
          qrController: _qrController,
          onLocationModeChanged: (value) {
            setState(() {
              _useCurrentLocation = value;
            });
          },
        );
      case 2:
        return _DurationStep(
          minutes: _selectedDurationMinutes,
          price: _priceForDuration(_selectedDurationMinutes),
          onDecrease: () {
            if (_selectedDurationMinutes == 30) return;
            setState(() {
              _selectedDurationMinutes -= 30;
            });
          },
          onIncrease: () {
            setState(() {
              _selectedDurationMinutes += 30;
            });
          },
        );
      default:
        return _PaymentStep(
          vehicle: _vehicles[_selectedVehicleIndex],
          durationLabel: _durationLabel(_selectedDurationMinutes),
          totalPrice: _priceForDuration(_selectedDurationMinutes),
          locationLabel: _locationLabel,
        );
    }
  }

  Widget _buildVehicleStep() {
    if (_isLoadingVehicles) {
      return const _WhiteCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_loadError != null) {
      return _WhiteCard(
        child: Column(
          children: [
            _ErrorBanner(message: _loadError!),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _loadVehicles,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return _WhiteCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'لا توجد مركبات مرتبطة بحسابك حتى الآن.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضيفي مركبة أولاً حتى نتمكن من بدء جلسة الوقوف على المركبة الصحيحة.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openVehicleForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة مركبة جديدة'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < _vehicles.length; index++) ...[
          _VehicleChoiceCard(
            vehicle: _vehicles[index],
            isSelected: _selectedVehicleIndex == index,
            onTap: () {
              setState(() {
                _selectedVehicleIndex = index;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _openVehicleForm,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            side: const BorderSide(color: Color(0xFF0F766E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة مركبة جديدة'),
        ),
      ],
    );
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
      _loadError = null;
    });

    try {
      final vehicles = await _vehicleService.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _selectedVehicleIndex = vehicles.isEmpty ? 0 : _safeSelectedIndex(vehicles.length);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingVehicles = false;
      });
    }
  }

  int _safeSelectedIndex(int length) {
    if (_selectedVehicleIndex >= length) {
      return 0;
    }
    return _selectedVehicleIndex;
  }

  Future<void> _openVehicleForm() async {
    final result = await Navigator.of(context).push<DriverVehicleFormResult>(
      MaterialPageRoute(
        builder: (_) => const DriverVehicleFormScreen(
          title: 'إضافة مركبة جديدة',
          actionLabel: 'إضافة المركبة',
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      await _vehicleService.addVehicle(
        licensePlate: result.plateNumber,
        vehicleType: result.vehicleType,
        color: result.color,
      );

      await _loadVehicles();
      if (!mounted) return;

      final newIndex = _vehicles.indexWhere(
        (vehicle) => vehicle.plateNumber == result.plateNumber,
      );

      setState(() {
        _selectedVehicleIndex = newIndex == -1 ? 0 : newIndex;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _goNext() async {
    setState(() {
      _submitError = null;
    });

    if (_currentStep == 0 && _vehicles.isEmpty) {
      setState(() {
        _submitError = 'يجب إضافة مركبة قبل بدء جلسة الوقوف.';
      });
      return;
    }

    if (_currentStep == 1 && !_useCurrentLocation && _qrController.text.trim().isEmpty) {
      setState(() {
        _submitError = 'أدخلي رمز QR أو كود الموقف قبل المتابعة.';
      });
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    if (_vehicles.isEmpty) {
      setState(() {
        _submitError = 'لا توجد مركبة صالحة لبدء الجلسة.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final selectedVehicle = _vehicles[_selectedVehicleIndex];
    final coordinates = _selectedCoordinates;
    final now = DateTime.now();

    try {
      await _parkingService.startSession(
        vehicleId: selectedVehicle.id,
        durationMinutes: _selectedDurationMinutes,
        lat: coordinates.$1,
        lng: coordinates.$2,
      );

      if (!mounted) return;

      Navigator.of(context).pop(
        DriverParkingSession(
          vehicleId: selectedVehicle.id,
          vehiclePlateNumber: selectedVehicle.plateNumber,
          vehicleModel: selectedVehicle.vehicleType,
          locationLabel: _locationLabel,
          paymentMethodLabel: 'المحفظة',
          durationMinutes: _selectedDurationMinutes,
          totalPrice: _priceForDuration(_selectedDurationMinutes),
          startedAt: now,
          endsAt: now.add(Duration(minutes: _selectedDurationMinutes)),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep -= 1;
      _submitError = null;
    });
  }

  (double, double) get _selectedCoordinates {
    return (_fallbackLatitude, _fallbackLongitude);
  }

  String get _locationLabel {
    if (_useCurrentLocation) {
      return 'الموقع الحالي';
    }

    final qr = _qrController.text.trim();
    return qr.isEmpty ? 'رمز QR' : 'رمز QR: $qr';
  }

  int _priceForDuration(int minutes) => minutes ~/ 30;

  String _durationLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    }

    final hours = minutes ~/ 60;
    final extraMinutes = minutes % 60;
    final hourLabel = hours == 1 ? 'ساعة' : '$hours ساعات';
    if (extraMinutes == 0) {
      return hourLabel;
    }
    return '$hourLabel و $extraMinutes دقيقة';
  }
}

class _VehicleChoiceCard extends StatelessWidget {
  const _VehicleChoiceCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  final DriverVehicle vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F2EF),
                borderRadius: BorderRadius.circular(16),
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
                    vehicle.plateNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.vehicleType} • ${vehicle.color ?? 'غير محدد'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EEE5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      vehicle.isDefault ? 'المركبة الأساسية' : 'مركبة مسجلة',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFB8B2A7),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.useCurrentLocation,
    required this.qrController,
    required this.onLocationModeChanged,
  });

  final bool useCurrentLocation;
  final TextEditingController qrController;
  final ValueChanged<bool> onLocationModeChanged;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChoiceTile(
            title: 'استخدام موقعي الحالي',
            subtitle: 'الربط الحالي يرسل إحداثيات ثابتة مؤقتاً إلى الباك إلى أن نربط GPS الحقيقي.',
            icon: Icons.my_location_rounded,
            selected: useCurrentLocation,
            onTap: () => onLocationModeChanged(true),
          ),
          const SizedBox(height: 12),
          _ChoiceTile(
            title: 'استخدام رمز QR',
            subtitle: 'يمكنك إدخال رمز الموقف هنا، لكن الباك حالياً لا يخزن الرمز نفسه بل يعتمد على الإحداثيات فقط.',
            icon: Icons.qr_code_2_rounded,
            selected: !useCurrentLocation,
            onTap: () => onLocationModeChanged(false),
          ),
          const SizedBox(height: 18),
          if (useCurrentLocation)
            const _InfoBox(
              text: 'نستخدم إحداثيات الخليل مؤقتاً حتى نربط الموقع الفعلي من الجهاز.',
            )
          else
            TextField(
              controller: qrController,
              decoration: const InputDecoration(
                labelText: 'رمز QR أو كود الموقف',
                prefixIcon: Icon(Icons.qr_code_scanner_rounded),
              ),
            ),
        ],
      ),
    );
  }
}

class _DurationStep extends StatelessWidget {
  const _DurationStep({
    required this.minutes,
    required this.price,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int minutes;
  final int price;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryLabel = minutes < 60 ? '$minutes دقيقة' : '${minutes ~/ 60 == 1 ? 'ساعة' : '${minutes ~/ 60} ساعات'}';
    final extraMinutes = minutes % 60;
    final secondaryLabel = extraMinutes == 0 || minutes < 60 ? null : 'و $extraMinutes دقيقة';
    final progress = (minutes / 180).clamp(0.2, 1.0);

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: progress.toDouble(),
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFE7E1D6),
                      color: const Color(0xFF0F766E),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  SizedBox(
                    width: 118,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          primaryLabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F766E),
                            fontSize: 22,
                          ),
                        ),
                        if (secondaryLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            secondaryLabel,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          '$price شيكل',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF5B6472),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: minutes == 30 ? null : onDecrease,
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('نقص نصف ساعة'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('زد نصف ساعة'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _InfoBox(
            text: 'الباك يحسب 1 شيكل لكل 30 دقيقة ويخصم المبلغ من المحفظة عند التأكيد.',
          ),
        ],
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.vehicle,
    required this.durationLabel,
    required this.totalPrice,
    required this.locationLabel,
  });

  final DriverVehicle vehicle;
  final String durationLabel;
  final int totalPrice;
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WhiteCard(
          child: Column(
            children: [
              _SummaryRow(label: 'المركبة', value: vehicle.plateNumber),
              _SummaryRow(label: 'النوع', value: vehicle.vehicleType),
              _SummaryRow(label: 'اللون', value: vehicle.color ?? 'غير محدد'),
              _SummaryRow(label: 'الموقع', value: locationLabel),
              _SummaryRow(label: 'المدة', value: durationLabel),
              _SummaryRow(label: 'المبلغ', value: '$totalPrice شيكل'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ChoiceTile(
          title: 'المحفظة',
          subtitle: 'هذه هي طريقة الدفع الفعلية المدعومة حالياً من الباك.',
          icon: Icons.account_balance_wallet_outlined,
          selected: true,
          onTap: _noop,
        ),
      ],
    );
  }
}

class _FlowMiniProgress extends StatelessWidget {
  const _FlowMiniProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['مركبة', 'موقع', 'مدة', 'دفع'];

    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineIndex = index ~/ 2;
          final isDone = currentStep > lineIndex;
          return Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: isDone ? const Color(0xFF0F766E) : const Color(0xFFD8D2C7),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isActive = currentStep == stepIndex;
        final isDone = currentStep > stepIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive || isDone ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isDone
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 44,
              child: Text(
                labels[stepIndex],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: isActive ? const Color(0xFF0F766E) : const Color(0xFF8A8F98),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F766E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF5B6472),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFF0F766E) : const Color(0xFFB8B2A7),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF36505A),
            ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5B6472),
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7E5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3B7AF)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7A2E24),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

void _noop() {}
