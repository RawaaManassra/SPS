import 'package:flutter/material.dart';

import 'package:flut/features/driver/parking/driver_parking_session.dart';
import 'package:flut/features/driver/vehicles/driver_vehicle_form_screen.dart';

class StartParkingScreen extends StatefulWidget {
  const StartParkingScreen({super.key});

  @override
  State<StartParkingScreen> createState() => _StartParkingScreenState();
}

class _StartParkingScreenState extends State<StartParkingScreen> {
  int _currentStep = 0;
  int _selectedVehicleIndex = 0;
  int _selectedDurationMinutes = 30;
  int _selectedPaymentIndex = 0;
  bool _useCurrentLocation = true;
  bool _isSubmitting = false;
  final TextEditingController _qrController = TextEditingController();

  final List<_VehicleItem> _vehicles = [
    const _VehicleItem(
      plateNumber: '24-381-15',
      model: 'Hyundai i20',
      color: 'أبيض',
      tag: 'المركبة الأساسية',
    ),
    const _VehicleItem(
      plateNumber: '31-662-08',
      model: 'Kia Picanto',
      color: 'فضي',
      tag: 'مركبة مضافة',
    ),
  ];

  static const _paymentMethods = [
    _PaymentMethod(title: 'المحفظة', subtitle: 'الرصيد المتاح: 42 شيكل'),
    _PaymentMethod(title: 'بطاقة بنكية', subtitle: 'Visa / Mastercard'),
    _PaymentMethod(title: 'Google Pay', subtitle: 'الدفع السريع من الهاتف'),
  ];

  static const _stepTitles = [
    'اختيار المركبة',
    'تأكيد الموقع',
    'اختيار المدة',
    'الدفع والتأكيد',
  ];

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
        return 'اختر المركبة التي تريد بدء جلسة الوقوف لها.';
      case 1:
        return 'يمكنك استخدام موقعك الحالي أو إدخال رمز QR الموجود في مكان الوقوف.';
      case 2:
        return 'أقل مدة للوقوف هي 30 دقيقة بسعر 1 شيكل، والسعر يزيد كل نصف ساعة.';
      default:
        return 'راجع تفاصيل الجلسة وطريقة الدفع قبل بدء الوقوف.';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _VehicleStep(
          vehicles: _vehicles,
          selectedIndex: _selectedVehicleIndex,
          onSelected: (index) {
            setState(() {
              _selectedVehicleIndex = index;
            });
          },
          onAddVehicle: _openVehicleForm,
        );
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
            if (_selectedDurationMinutes == 30) {
              return;
            }
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
          duration: _DurationOption(
            minutes: _selectedDurationMinutes,
            price: _priceForDuration(_selectedDurationMinutes),
          ),
          locationLabel: _locationLabel,
          methods: _paymentMethods,
          selectedMethodIndex: _selectedPaymentIndex,
          onPaymentSelected: (index) {
            setState(() {
              _selectedPaymentIndex = index;
            });
          },
        );
    }
  }

  String get _locationLabel {
    if (_useCurrentLocation) {
      return 'الموقع الحالي';
    }

    final qr = _qrController.text.trim();
    return qr.isEmpty ? 'رمز QR' : 'رمز QR: $qr';
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

    setState(() {
      _vehicles.add(
        _VehicleItem(
          plateNumber: result.plateNumber,
          model: result.vehicleType,
          color: result.color,
          tag: 'مركبة مضافة',
        ),
      );
      _selectedVehicleIndex = _vehicles.length - 1;
    });
  }

  Future<void> _goNext() async {
    if (_currentStep == 1 && !_useCurrentLocation && _qrController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل رمز QR أو كود الموقف قبل المتابعة.'),
        ),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    final now = DateTime.now();
    final duration = Duration(minutes: _selectedDurationMinutes);
    final selectedVehicle = _vehicles[_selectedVehicleIndex];
    final selectedPaymentMethod = _paymentMethods[_selectedPaymentIndex];

    Navigator.of(context).pop(
      DriverParkingSession(
        vehiclePlateNumber: selectedVehicle.plateNumber,
        vehicleModel: selectedVehicle.model,
        locationLabel: _locationLabel,
        paymentMethodLabel: selectedPaymentMethod.title,
        durationMinutes: _selectedDurationMinutes,
        totalPrice: _priceForDuration(_selectedDurationMinutes),
        startedAt: now,
        endsAt: now.add(duration),
      ),
    );
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep -= 1;
    });
  }

  int _priceForDuration(int minutes) {
    return minutes ~/ 30;
  }
}

class _VehicleStep extends StatelessWidget {
  const _VehicleStep({
    required this.vehicles,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAddVehicle,
  });

  final List<_VehicleItem> vehicles;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < vehicles.length; index++) ...[
          _VehicleChoiceCard(
            vehicle: vehicles[index],
            isSelected: selectedIndex == index,
            onTap: () => onSelected(index),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: onAddVehicle,
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
            subtitle: 'قف في مكان الوقوف واسمح للتطبيق بالوصول إلى الموقع.',
            icon: Icons.my_location_rounded,
            selected: useCurrentLocation,
            onTap: () => onLocationModeChanged(true),
          ),
          const SizedBox(height: 12),
          _ChoiceTile(
            title: 'استخدام رمز QR',
            subtitle: 'إذا لم ترغب في تفعيل الموقع، أدخل رمز QR الموجود في مكان الوقوف.',
            icon: Icons.qr_code_2_rounded,
            selected: !useCurrentLocation,
            onTap: () => onLocationModeChanged(false),
          ),
          const SizedBox(height: 18),
          if (useCurrentLocation)
            const _InfoBox(
              text: 'سيتم استخدام موقعك الحالي لتسجيل مكان الجلسة وإظهاره لاحقاً على الخريطة.',
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
    final durationOption = _DurationOption(minutes: minutes, price: price);
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
                          durationOption.primaryLabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F766E),
                            fontSize: 22,
                          ),
                        ),
                        if (durationOption.secondaryLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            durationOption.secondaryLabel!,
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
            text: 'كل 30 دقيقة = 1 شيكل، ويمكنك تمديد الوقت لاحقاً بعد تأكيد الدفع.',
          ),
        ],
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.vehicle,
    required this.duration,
    required this.locationLabel,
    required this.methods,
    required this.selectedMethodIndex,
    required this.onPaymentSelected,
  });

  final _VehicleItem vehicle;
  final _DurationOption duration;
  final String locationLabel;
  final List<_PaymentMethod> methods;
  final int selectedMethodIndex;
  final ValueChanged<int> onPaymentSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _WhiteCard(
          child: Column(
            children: [
              _SummaryRow(label: 'المركبة', value: vehicle.plateNumber),
              _SummaryRow(label: 'النوع', value: vehicle.model),
              _SummaryRow(label: 'اللون', value: vehicle.color),
              _SummaryRow(label: 'الموقع', value: locationLabel),
              _SummaryRow(label: 'المدة', value: duration.label),
              _SummaryRow(label: 'المبلغ', value: '${duration.price} شيكل'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'طريقة الدفع',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < methods.length; index++) ...[
          _ChoiceTile(
            title: methods[index].title,
            subtitle: methods[index].subtitle,
            icon: index == 0
                ? Icons.account_balance_wallet_outlined
                : index == 1
                    ? Icons.credit_card_rounded
                    : Icons.phone_android_rounded,
            selected: selectedMethodIndex == index,
            onTap: () => onPaymentSelected(index),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _VehicleChoiceCard extends StatelessWidget {
  const _VehicleChoiceCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  final _VehicleItem vehicle;
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
                    '${vehicle.model} • ${vehicle.color}',
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
                      vehicle.tag,
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
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFB8B2A7),
            ),
          ],
        ),
      ),
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
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFF0F766E) : const Color(0xFFB8B2A7),
            ),
          ],
        ),
      ),
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
                color: isActive || isDone
                    ? const Color(0xFF0F766E)
                    : const Color(0xFFE7E1D6),
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

class _VehicleItem {
  const _VehicleItem({
    required this.plateNumber,
    required this.model,
    required this.color,
    required this.tag,
  });

  final String plateNumber;
  final String model;
  final String color;
  final String tag;
}

class _DurationOption {
  const _DurationOption({
    required this.minutes,
    required this.price,
  });

  final int minutes;
  final int price;

  String get label {
    if (secondaryLabel == null) {
      return primaryLabel;
    }
    return '$primaryLabel ${secondaryLabel!}';
  }

  String get primaryLabel {
    if (minutes < 60) {
      return '$minutes دقيقة';
    }

    final hours = minutes ~/ 60;
    return hours == 1 ? 'ساعة' : '$hours ساعات';
  }

  String? get secondaryLabel {
    if (minutes < 60) {
      return null;
    }

    final extraMinutes = minutes % 60;
    if (extraMinutes == 0) {
      return null;
    }

    return 'و $extraMinutes دقيقة';
  }
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}
