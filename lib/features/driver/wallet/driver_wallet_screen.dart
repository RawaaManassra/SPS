import 'package:flutter/material.dart';

import 'package:flut/features/driver/wallet/models/driver_wallet.dart';
import 'package:flut/features/driver/wallet/models/driver_wallet_transaction.dart';
import 'package:flut/features/driver/wallet/services/wallet_service.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  final _walletService = WalletService();

  DriverWallet? _wallet;
  List<DriverWalletTransaction> _transactions = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wallet = await _walletService.getWallet();
      final transactions = await _walletService.getTransactions();

      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _transactions = transactions.reversed.toList();
      });
    } on WalletException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذر تحميل بيانات المحفظة حالياً.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openChargeWalletFlow() async {
    final result = await Navigator.of(context).push<_WalletChargeResult>(
      MaterialPageRoute(
        builder: (_) => const WalletChargeScreen(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _walletService.topUpWallet(amount: result.amount);
      await _loadWalletData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم شحن المحفظة بمبلغ ${result.amount} شيكل بنجاح.',
          ),
        ),
      );
    } on WalletException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر شحن المحفظة حالياً.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = _wallet?.balance ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadWalletData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF17867D),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'الرصيد الحالي',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const SizedBox(
                      height: 36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      '${balance.toStringAsFixed(2)} شيكل',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading || _isSubmitting ? null : _openChargeWalletFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Text('شحن المحفظة'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_errorMessage != null)
              _WalletErrorState(
                message: _errorMessage!,
                onRetry: _loadWalletData,
              )
            else if (_isLoading)
              const _WalletLoadingState()
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'سجل عمليات المحفظة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_transactions.isEmpty)
                      const _EmptyTransactionsState()
                    else
                      ...List.generate(_transactions.length, (index) {
                        final item = _transactions[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _transactions.length - 1 ? 0 : 12,
                          ),
                          child: _WalletTransactionCard(item: item),
                        );
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WalletChargeScreen extends StatefulWidget {
  const WalletChargeScreen({super.key});

  @override
  State<WalletChargeScreen> createState() => _WalletChargeScreenState();
}

class _WalletChargeScreenState extends State<WalletChargeScreen> {
  int _currentStep = 0;
  int _selectedAmount = 20;
  int _selectedPaymentIndex = 0;
  bool _isSubmitting = false;

  static const _paymentMethods = [
    _WalletPaymentMethod(
      title: 'بطاقة بنكية',
      subtitle: 'Visa / Mastercard',
      icon: Icons.credit_card_rounded,
    ),
    _WalletPaymentMethod(
      title: 'Jawwal Pay',
      subtitle: 'الدفع من المحفظة الرقمية',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _WalletPaymentMethod(
      title: 'Google Pay',
      subtitle: 'الدفع السريع من الهاتف',
      icon: Icons.phone_android_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('شحن المحفظة'),
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
                _currentStep == 0 ? 'اختيار مبلغ الشحن' : 'الدفع والتأكيد',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 0
                    ? 'اختر قيمة الرصيد التي تريد إضافتها إلى المحفظة.'
                    : 'راجع مبلغ الشحن واختر طريقة الدفع قبل التأكيد.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55606E),
                ),
              ),
              const SizedBox(height: 18),
              _currentStep == 0 ? _buildAmountStep() : _buildPaymentStep(),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _goNext,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : Text(_currentStep == 1 ? 'تأكيد الدفع والشحن' : 'متابعة'),
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
              if (_currentStep == 1) ...[
                const SizedBox(height: 12),
                const _InfoBox(
                  text: 'مهم: الباك الحالي يسجل مبلغ الشحن فقط، أما طريقة الدفع فهي معروضة هنا كجزء من تجربة الواجهة.',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountStep() {
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
                  const SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: 12,
                      backgroundColor: Color(0xFFE7E1D6),
                      color: Color(0xFF0F766E),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_selectedAmount',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: const Color(0xFF0F766E),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        'شيكل',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF5B6472),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
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
                  onPressed: _selectedAmount == 10
                      ? null
                      : () {
                          setState(() {
                            _selectedAmount -= 10;
                          });
                        },
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('نقص 10'),
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
                      _selectedAmount += 10;
                    });
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('زد 10'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _InfoBox(
            text: 'يمكنك زيادة مبلغ الشحن على شكل مضاعفات 10 شيكل.',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      children: [
        _WhiteCard(
          child: Column(
            children: [
              _SummaryRow(label: 'مبلغ الشحن', value: '$_selectedAmount شيكل'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'طريقة الدفع',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_paymentMethods.length, (index) {
          final method = _paymentMethods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChoiceTile(
              title: method.title,
              subtitle: method.subtitle,
              icon: method.icon,
              selected: _selectedPaymentIndex == index,
              onTap: () {
                setState(() {
                  _selectedPaymentIndex = index;
                });
              },
            ),
          );
        }),
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

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(
      _WalletChargeResult(
        amount: _selectedAmount,
        paymentMethod: _paymentMethods[_selectedPaymentIndex].title,
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
}

class _WalletTransactionCard extends StatelessWidget {
  const _WalletTransactionCard({
    required this.item,
  });

  final DriverWalletTransaction item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = item.transactionType == 'top_up' || item.transactionType == 'refund';
    final color = isPositive ? const Color(0xFF0F766E) : const Color(0xFFD63C31);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPositive ? Icons.add_card_rounded : Icons.payments_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _titleForType(item.transactionType),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      _timeLabel(item.createdAt),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitleForType(item),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isPositive ? '+' : '-'}${item.amount} شيكل',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _titleForType(String type) {
    switch (type) {
      case 'top_up':
        return 'شحن المحفظة';
      case 'session_start':
        return 'دفع جلسة وقوف';
      case 'session_extension':
        return 'تمديد جلسة وقوف';
      case 'refund':
        return 'استرداد رصيد';
      default:
        return 'عملية محفظة';
    }
  }

  String _subtitleForType(DriverWalletTransaction transaction) {
    if (transaction.sessionId != null) {
      return 'مرتبطة بالجلسة ${transaction.sessionId}';
    }

    switch (transaction.transactionType) {
      case 'top_up':
        return 'تمت إضافة رصيد إلى المحفظة';
      case 'refund':
        return 'تم إرجاع مبلغ إلى المحفظة';
      default:
        return 'عملية محفوظة في الباك';
    }
  }

  String _timeLabel(DateTime? createdAt) {
    if (createdAt == null) {
      return 'غير محدد';
    }

    final localTime = createdAt.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    }

    if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} د';
    }

    if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} س';
    }

    return '${localTime.day}/${localTime.month}/${localTime.year}';
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['مبلغ', 'دفع'];

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
                      color: isActive
                          ? const Color(0xFF0F766E)
                          : const Color(0xFF8A8F98),
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

class _WalletLoadingState extends StatelessWidget {
  const _WalletLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _WalletErrorState extends StatelessWidget {
  const _WalletErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD63C31),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'تعذر تحميل المحفظة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'لا توجد عمليات محفوظة في المحفظة حالياً.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B6472),
            ),
      ),
    );
  }
}

class _WalletPaymentMethod {
  const _WalletPaymentMethod({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _WalletChargeResult {
  const _WalletChargeResult({
    required this.amount,
    required this.paymentMethod,
  });

  final int amount;
  final String paymentMethod;
}
