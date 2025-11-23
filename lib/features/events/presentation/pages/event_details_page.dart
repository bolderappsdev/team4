import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// First page in the event creation process (1/4).
/// Collects basic event details: title, theme, description, date, time, and location.
class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedTheme;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  static const List<String> _themes = [
    'Healthcare',
    'Education',
    'Economy',
    'Environment',
    'Infrastructure',
    'Public Safety',
    'Housing',
    'Transportation',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F1728),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F1728),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F1728),
              ),
            ),
            const SizedBox(height: 16),
            ..._themes.map((theme) {
              return ListTile(
                title: Text(theme),
                trailing: _selectedTheme == theme
                    ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTheme = theme;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTheme == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a theme'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // TODO: Navigate to next page (Ticketing page - 2/4)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Continue to Ticketing - Coming soon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF0F1728),
                            size: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Event Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF0F1728),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.75,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          '1/4',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 16,
                            fontFamily: 'Futura PT',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEAECF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFEAECF0),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        const Text(
                          'Basic Event Details',
                          style: TextStyle(
                            color: Color(0xFF0A0A0A),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                            letterSpacing: -0.31,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Event Title
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Title *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: TextFormField(
                                controller: _titleController,
                                style: const TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Event title is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Theme
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Theme *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _showThemePicker,
                              child: Container(
                                width: double.infinity,
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF3F3F5),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFCAD5E2),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _selectedTheme ?? 'Select a theme',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedTheme == null
                                            ? const Color(0xFF717182)
                                            : const Color(0xFF0A0A0A),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                        letterSpacing: -0.15,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: Color(0xFF717182),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Event Description
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Description *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 128,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Provide details about your event, what attendees can expect, key speakers, agenda, etc.',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF0A0A0A),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                    letterSpacing: -0.31,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Event description is required';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_descriptionController.text.length} characters',
                              style: const TextStyle(
                                color: Color(0xFF61738D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: -0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Date and Time Row
                        Row(
                          children: [
                            // Date
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date *',
                                    style: TextStyle(
                                      color: Color(0xFF314157),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _selectDate,
                                    child: Container(
                                      width: double.infinity,
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF3F3F5),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFCAD5E2),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            _selectedDate != null
                                                ? DateFormat('MMM dd, yyyy')
                                                    .format(_selectedDate!)
                                                : 'Select date',
                                            style: TextStyle(
                                              color: _selectedDate == null
                                                  ? const Color(0xFF717182)
                                                  : const Color(0xFF0A0A0A),
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                              letterSpacing: -0.31,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Color(0xFF717182),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Time
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time *',
                                    style: TextStyle(
                                      color: Color(0xFF314157),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _selectTime,
                                    child: Container(
                                      width: double.infinity,
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF3F3F5),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFCAD5E2),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            _selectedTime != null
                                                ? _selectedTime!.format(context)
                                                : 'Select time',
                                            style: TextStyle(
                                              color: _selectedTime == null
                                                  ? const Color(0xFF717182)
                                                  : const Color(0xFF0A0A0A),
                                              fontSize: 16,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.50,
                                              letterSpacing: -0.31,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Color(0xFF717182),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Location
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location *',
                              style: TextStyle(
                                color: Color(0xFF314157),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1,
                                letterSpacing: -0.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 44,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F3F5),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFCAD5E2),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.location_on,
                                    size: 20,
                                    color: Color(0xFF717182),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _locationController,
                                      style: const TextStyle(
                                        color: Color(0xFF0A0A0A),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.50,
                                        letterSpacing: -0.31,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Location is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Enter the full address or venue name',
                              style: TextStyle(
                                color: Color(0xFF61738D),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: -0.15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Button Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Continue to Ticketing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bottom indicator (home indicator for iOS)
                  Container(
                    width: 134,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

