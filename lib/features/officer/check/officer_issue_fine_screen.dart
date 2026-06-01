import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flut/features/officer/check/models/officer_vehicle_check_result.dart';
import 'package:flut/features/officer/check/models/officer_violation_type.dart';
import 'package:flut/features/officer/check/services/officer_inspector_service.dart';

class OfficerIssueFineScreen extends StatefulWidget {
  const OfficerIssueFineScreen({
    super.key,
    required this.result,
  });

  final OfficerVehicleCheckResult result;

  @override
  State<OfficerIssueFineScreen> createState() => _OfficerIssueFineScreenState();
}

class _OfficerIssueFineScreenState extends State<OfficerIssueFineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = OfficerInspectorService();
  final _imagePicker = ImagePicker();
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _isLoadingTypes = true;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  List<OfficerViolationType> _violationTypes = const [];
  OfficerViolationType? _selectedType;
  String? _evidenceImagePath;
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController(
      text: (widget.result.latitude ?? 31.5326).toString(),
    );
    _longitudeController = TextEditingController(
      text: (widget.result.longitude ?? 35.0998).toString(),
    );
    _loadViolationTypes();
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إصدار مخالفة'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.result.licensePlate,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.result.vehicleType ?? 'نوع غير محدد'} • ${widget.result.color ?? 'لون غير محدد'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'نوع المخالفة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingTypes)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_violationTypes.isEmpty)
                    Text(
                      'لا توجد أنواع مخالفات متاحة حالياً.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6472),
                      ),
                    )
                  else
                    _SelectedViolationTypeCard(
                      violationType: _selectedType,
                      onTap: _showViolationTypePicker,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'صورة الدليل',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _EvidenceImageCard(
                    hasImage: _evidenceImagePath != null,
                    isUploading: _isUploadingImage,
                    fileName: _evidenceImagePath == null ? null : _fileNameFromPath(_evidenceImagePath!),
                    onCameraTap: _isUploadingImage ? null : () => _pickEvidenceImage(ImageSource.camera),
                    onGalleryTap: _isUploadingImage ? null : () => _pickEvidenceImage(ImageSource.gallery),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'موقع تسجيل المخالفة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _requiredCoordinateValidator,
                    decoration: const InputDecoration(
                      labelText: 'خط العرض (Latitude)',
                      prefixIcon: Icon(Icons.my_location_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: _requiredCoordinateValidator,
                    decoration: const InputDecoration(
                      labelText: 'خط الطول (Longitude)',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitFine,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.gavel_rounded),
                    label: Text(_isSubmitting ? 'جارٍ إصدار المخالفة...' : 'إصدار المخالفة'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadViolationTypes() async {
    try {
      final types = await _service.getViolationTypes();
      if (!mounted) return;
      setState(() {
        _violationTypes = types;
        _selectedType = types.isEmpty ? null : types.first;
      });
    } on OfficerInspectorException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  Future<void> _pickEvidenceImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile == null || !mounted) return;

      setState(() {
        _evidenceImagePath = pickedFile.path;
        _uploadedPhotoUrl = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر اختيار الصورة حالياً.')),
      );
    }
  }

  Future<void> _submitFine() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختري نوع المخالفة أولاً.')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_evidenceImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضيفي صورة دليل للسيارة قبل إصدار المخالفة.')),
      );
      return;
    }

    final vehicleId = widget.result.vehicleId;
    if (vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديد المركبة المطلوبة لإصدار المخالفة.')),
      );
      return;
    }

    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخلي إحداثيات صحيحة للموقع.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final photoUrl = _uploadedPhotoUrl ?? await _uploadEvidenceImage();
      await _service.issueFine(
        vehicleId: vehicleId,
        violationTypeId: _selectedType!.id,
        latitude: latitude,
        longitude: longitude,
        photoUrl: photoUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إصدار المخالفة بنجاح.')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on OfficerInspectorException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<String> _uploadEvidenceImage() async {
    final imagePath = _evidenceImagePath;
    if (imagePath == null) {
      throw const OfficerInspectorException(
        'أضيفي صورة دليل قبل إصدار المخالفة.',
      );
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final photoUrl = await _service.uploadEvidenceImage(imagePath);
      if (!mounted) return photoUrl;
      setState(() {
        _uploadedPhotoUrl = photoUrl;
      });
      return photoUrl;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  String? _requiredCoordinateValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(text) == null) {
      return 'أدخلي قيمة رقمية صحيحة';
    }
    return null;
  }

  String _fileNameFromPath(String path) {
    final parts = path.replaceAll('\\', '/').split('/');
    return parts.isEmpty ? path : parts.last;
  }

  Future<void> _showViolationTypePicker() async {
    if (_violationTypes.isEmpty) return;

    final selected = await showModalBottomSheet<OfficerViolationType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 480),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'اختيار نوع المخالفة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _violationTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final type = _violationTypes[index];
                      final isSelected = _selectedType?.id == type.id;

                      return _ViolationTypeTile(
                        violationType: type,
                        isSelected: isSelected,
                        onTap: () => Navigator.of(context).pop(type),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() {
      _selectedType = selected;
    });
  }
}

class _EvidenceImageCard extends StatelessWidget {
  const _EvidenceImageCard({
    required this.hasImage,
    required this.isUploading,
    required this.fileName,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final bool hasImage;
  final bool isUploading;
  final String? fileName;
  final VoidCallback? onCameraTap;
  final VoidCallback? onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasImage ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasImage ? Icons.check_circle_rounded : Icons.photo_camera_outlined,
                  color: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasImage ? 'تم اختيار صورة الدليل' : 'صورة الدليل مطلوبة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileName ?? 'أضيفي صورة واضحة للسيارة قبل إصدار المخالفة.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5B6472),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isUploading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCameraTap,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('فتح الكاميرا'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGalleryTap,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('من المعرض'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViolationTypeTile extends StatelessWidget {
  const _ViolationTypeTile({
    required this.violationType,
    required this.isSelected,
    required this.onTap,
  });

  final OfficerViolationType violationType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE7F2EF) : const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFE7E1D6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violationType.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${violationType.amount.toStringAsFixed(0)} شيكل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF9AA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedViolationTypeCard extends StatelessWidget {
  const _SelectedViolationTypeCard({
    required this.violationType,
    required this.onTap,
  });

  final OfficerViolationType? violationType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7F3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7E1D6)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.report_gmailerrorred_outlined,
              color: Color(0xFF0F766E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violationType?.name ?? 'اختيار نوع المخالفة',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    violationType == null
                        ? 'افتح القائمة لاختيار نوع المخالفة'
                        : '${violationType!.amount.toStringAsFixed(0)} شيكل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5B6472),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF5B6472),
            ),
          ],
        ),
      ),
    );
  }
}
