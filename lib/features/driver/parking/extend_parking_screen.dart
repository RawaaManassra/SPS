import 'package:flutter/material.dart';

class ExtendParkingScreen extends StatefulWidget {
  const ExtendParkingScreen({super.key});

  @override
  State<ExtendParkingScreen> createState() => _ExtendParkingScreenState();
}

class _ExtendParkingScreenState extends State<ExtendParkingScreen> {
  int _currentStep = 0;
  int _selectedExtraMinutes = 30;
  bool _isSubmitting = false;

  static const _stepTitles = [
    'اختيار مدة التمديد',
    'التأكيد والدفع',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تمديد الوقت'),
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
                'الخطوة ${_currentStep + 1} من 2',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF0F766E),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _MiniProgress(currentStep: _currentStep),
              const SizedBox(height: 18),
              Text(
                _stepTitles[_currentStep],
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 0
                    ? 'اختري الوقت الذي تريدين إضافته إلى الجلسة الحالية.'
                    : 'سيتم خصم قيمة التمديد من المحفظة مباشرة عند التأكيد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55606E),
                ),
              ),
              const SizedBox(height: 18),
              _currentStep == 0 ? _buildDurationStep() : _buildConfirmationStep(),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _goNext,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : Text(_currentStep == 1 ? 'تأكيد التمديد' : 'متابعة'),
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

  Widget _buildDurationStep() {
    final addedPrice = _selectedExtraMinutes ~/ 30;
    final durationOption = _ExtendDurationOption(minutes: _selectedExtraMinutes, price: addedPrice);
    final progress = (_selectedExtraMinutes / 180).clamp(0.2, 1.0);

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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F766E),
                                ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          '+$addedPrice شيكل',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  onPressed: _selectedExtraMinutes == 30
                      ? null
                      : () {
                          setState(() {
                            _selectedExtraMinutes -= 30;
                          });
                        },
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
                  onPressed: () {
                    setState(() {
                      _selectedExtraMinutes += 30;
                    });
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('زد نصف ساعة'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _InfoBox(
            text: 'التمديد الحقيقي في الباك يتم من خلال خصم المبلغ من المحفظة فقط.',
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    final addedPrice = _selectedExtraMinutes ~/ 30;

    return Column(
      children: [
        _WhiteCard(
          child: Column(
            children: [
              _SummaryRow(label: 'مدة التمديد', value: durationLabel(_selectedExtraMinutes)),
              _SummaryRow(label: 'قيمة الإضافة', value: '$addedPrice شيكل'),
              const _SummaryRow(label: 'طريقة الدفع', value: 'المحفظة'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _InfoBox(
          text: 'بعد التأكيد سيرسل التطبيق طلب تمديد إلى الباك، وإذا كان الرصيد غير كافٍ سيظهر لك تنبيه مناسب.',
        ),
      ],
    );
  }

  Future<void> _goNext() async {
    if (_currentStep == 0) {
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      ExtendParkingResult(
        extraMinutes: _selectedExtraMinutes,
      ),
    );
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep = 0;
    });
  }

  String durationLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes دقيقة';
    }

    final hours = minutes ~/ 60;
    final extraMinutes = minutes % 60;

    if (extraMinutes == 0) {
      return hours == 1 ? 'ساعة واحدة' : '$hours ساعات';
    }

    return '${hours == 1 ? 'ساعة' : '$hours ساعات'} و $extraMinutes دقيقة';
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['مدة', 'تأكيد'];

    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          final isDone = currentStep > 0;
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

class _ExtendDurationOption {
  const _ExtendDurationOption({
    required this.minutes,
    required this.price,
  });

  final int minutes;
  final int price;

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

class ExtendParkingResult {
  const ExtendParkingResult({
    required this.extraMinutes,
  });

  final int extraMinutes;
}
