import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/models/sleep.dart';

class SleepFormScreen extends StatefulWidget {
  final String babyId;
  final Sleep? sleep; // null untuk add, ada value untuk edit

  const SleepFormScreen({
    super.key,
    required this.babyId,
    this.sleep,
  });

  @override
  State<SleepFormScreen> createState() => _SleepFormScreenState();
}

class _SleepFormScreenState extends State<SleepFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  bool _isLoading = false;
  bool _isCurrentlySleeping = false;

  bool get isEditing => widget.sleep != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeFormWithSleepData();
    }
  }

  void _initializeFormWithSleepData() {
    final sleep = widget.sleep!;
    _startTime = sleep.startTime;
    _endTime = sleep.endTime;
    if (sleep.notes != null) {
      _notesController.text = sleep.notes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          
          // Adjust end time if it's before start time
          if (_endTime != null && _endTime!.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endTime ?? _startTime.add(const Duration(hours: 1)),
      firstDate: _startTime,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime != null 
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.fromDateTime(_startTime.add(const Duration(hours: 1))),
      );
      
      if (pickedTime != null) {
        setState(() {
          _endTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _setCurrentlySleeping() {
    setState(() {
      _isCurrentlySleeping = !_isCurrentlySleeping;
      if (_isCurrentlySleeping) {
        _endTime = null;
      } else {
        _endTime = DateTime.now();
      }
    });
  }

  Duration? get sleepDuration {
    if (_endTime == null) return null;
    return _endTime!.difference(_startTime);
  }

  String get durationText {
    final duration = sleepDuration;
    if (duration == null) return 'Masih tidur';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  Future<void> _saveSleep() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isCurrentlySleeping && _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai harus dipilih')),
      );
      return;
    }
    
    if (_endTime != null && _endTime!.isBefore(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai tidak boleh sebelum waktu mulai')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi save (dalam implementasi nyata akan save ke database/API)
    await Future.delayed(const Duration(seconds: 1));

    final sleep = Sleep(
      id: isEditing 
          ? widget.sleep!.id 
          : DateTime.now().millisecondsSinceEpoch.toString(),
      babyId: widget.babyId,
      startTime: _startTime,
      endTime: _endTime ?? DateTime.now(), // Use current time if still sleeping
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop(sleep);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing 
              ? 'Data tidur berhasil diupdate' 
              : 'Data tidur berhasil ditambahkan'),
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
        title: Text(isEditing ? 'Edit Tidur' : 'Catat Tidur'),
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
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.bedtime,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu Tidur',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Catat waktu tidur dan bangun bayi',
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

              // Currently Sleeping Toggle
              if (!isEditing) ...[
                Card(
                  child: SwitchListTile(
                    title: const Text('Sedang Tidur'),
                    subtitle: const Text('Aktifkan jika bayi sedang tidur sekarang'),
                    value: _isCurrentlySleeping,
                    onChanged: (value) => _setCurrentlySleeping(),
                    secondary: Icon(
                      _isCurrentlySleeping ? Icons.bedtime : Icons.bedtime_off,
                      color: _isCurrentlySleeping ? Colors.purple : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Start Time
              Text(
                'Waktu Mulai Tidur',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Waktu Mulai'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_startTime),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _selectStartTime,
                ),
              ),

              const SizedBox(height: 16),

              // End Time
              if (!_isCurrentlySleeping) ...[
                Text(
                  'Waktu Bangun',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('Waktu Bangun'),
                    subtitle: Text(
                      _endTime != null 
                          ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_endTime!)
                          : 'Pilih waktu bangun',
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: _selectEndTime,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Duration Display
              if (_endTime != null || _isCurrentlySleeping) ...[
                Card(
                  color: Colors.purple.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.purple),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Durasi Tidur',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              durationText,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  hintText: 'Tambahkan catatan tentang kualitas tidur...',
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSleep,
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
                      : Text(isEditing ? 'Simpan Perubahan' : 'Simpan Data'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
