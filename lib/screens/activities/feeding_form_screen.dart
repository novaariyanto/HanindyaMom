import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/models/feeding.dart';

class FeedingFormScreen extends StatefulWidget {
  final String babyId;
  final Feeding? feeding; // null untuk add, ada value untuk edit

  const FeedingFormScreen({
    super.key,
    required this.babyId,
    this.feeding,
  });

  @override
  State<FeedingFormScreen> createState() => _FeedingFormScreenState();
}

class _FeedingFormScreenState extends State<FeedingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  FeedingType _selectedType = FeedingType.breastLeft;
  DateTime _startTime = DateTime.now();
  bool _isLoading = false;

  bool get isEditing => widget.feeding != null;
  bool get showAmountField => _selectedType == FeedingType.formula;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeFormWithFeedingData();
    }
  }

  void _initializeFormWithFeedingData() {
    final feeding = widget.feeding!;
    _selectedType = feeding.type;
    _startTime = feeding.startTime;
    _durationController.text = feeding.durationMinutes.toString();
    if (feeding.amount != null) {
      _amountController.text = feeding.amount.toString();
    }
    if (feeding.notes != null) {
      _notesController.text = feeding.notes!;
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveFeeding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi save (dalam implementasi nyata akan save ke database/API)
    await Future.delayed(const Duration(seconds: 1));

    final feeding = Feeding(
      id: isEditing 
          ? widget.feeding!.id 
          : DateTime.now().millisecondsSinceEpoch.toString(),
      babyId: widget.babyId,
      type: _selectedType,
      startTime: _startTime,
      durationMinutes: int.parse(_durationController.text),
      amount: showAmountField && _amountController.text.isNotEmpty
          ? double.tryParse(_amountController.text)
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop(feeding);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing 
              ? 'Feeding berhasil diupdate' 
              : 'Feeding berhasil ditambahkan'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Feeding' : 'Tambah Feeding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feeding',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Catat waktu menyusui atau memberi formula',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Feeding Type
              Text(
                'Jenis Feeding',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: FeedingType.values.map((type) {
                    return RadioListTile<FeedingType>(
                      title: Row(
                        children: [
                          Icon(_getFeedingIcon(type), size: 20),
                          const SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                      value: type,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Start Time
              Text(
                'Waktu Mulai',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Waktu Mulai'),
                  subtitle: Text(DateFormat('HH:mm').format(_startTime)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _selectStartTime,
                ),
              ),

              const SizedBox(height: 24),

              // Duration
              Text(
                'Durasi (menit)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 15',
                  prefixIcon: Icon(Icons.timer),
                  suffixText: 'menit',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Durasi tidak boleh kosong';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Durasi harus berupa angka positif';
                  }
                  if (duration > 120) {
                    return 'Durasi tidak boleh lebih dari 120 menit';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Amount (only for formula)
              if (showAmountField) ...[
                Text(
                  'Jumlah Formula (ml)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: 120',
                    prefixIcon: Icon(Icons.local_drink),
                    suffixText: 'ml',
                  ),
                  validator: (value) {
                    if (showAmountField && (value == null || value.isEmpty)) {
                      return 'Jumlah formula tidak boleh kosong';
                    }
                    if (value != null && value.isNotEmpty) {
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Jumlah harus berupa angka positif';
                      }
                      if (amount > 500) {
                        return 'Jumlah tidak boleh lebih dari 500ml';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              Text(
                'Catatan (Opsional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan jika perlu...',
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFeeding,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(isEditing ? 'Simpan Perubahan' : 'Simpan Feeding'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFeedingIcon(FeedingType type) {
    switch (type) {
      case FeedingType.breastLeft:
      case FeedingType.breastRight:
        return Icons.child_care;
      case FeedingType.formula:
        return Icons.local_drink;
      case FeedingType.pump:
        return Icons.opacity;
    }
  }
}
