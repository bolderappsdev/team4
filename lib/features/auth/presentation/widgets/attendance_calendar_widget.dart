import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calendar widget for attendance page showing current month and selected date.
class AttendanceCalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<DateTime> eventDates;
  final Function(DateTime) onDateSelected;

  const AttendanceCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.eventDates,
    required this.onDateSelected,
  });

  @override
  State<AttendanceCalendarWidget> createState() =>
      _AttendanceCalendarWidgetState();
}

class _AttendanceCalendarWidgetState extends State<AttendanceCalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(AttendanceCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
      _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _hasEventOnDate(DateTime date) {
    return widget.eventDates.any((eventDate) =>
        eventDate.year == date.year &&
        eventDate.month == date.month &&
        eventDate.day == date.day);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // Find the first day of the week (Monday = 1, Sunday = 7)
    // We want to show Monday first, so we need to adjust
    int firstWeekday = firstDay.weekday;
    
    // Convert to Monday-based (0 = Monday, 6 = Sunday)
    int mondayBasedWeekday = (firstWeekday - 1) % 7;
    
    final days = <DateTime>[];
    
    // Add days from previous month to fill the first week
    for (int i = mondayBasedWeekday - 1; i >= 0; i--) {
      days.add(firstDay.subtract(Duration(days: i + 1)));
    }
    
    // Add days of current month
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    
    // Fill remaining days to complete the last week (if needed)
    final remainingDays = 7 - (days.length % 7);
    if (remainingDays > 0 && remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        days.add(lastDay.add(Duration(days: i)));
      }
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_currentMonth);
    final daysInMonth = _getDaysInMonth();
    final weeks = <List<DateTime>>[];
    
    for (int i = 0; i < daysInMonth.length; i += 7) {
      weeks.add(daysInMonth.sublist(i, i + 7));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 60,
            offset: Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month name and navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthName,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 17,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.41,
                    ),
                  ),
                ],
              ),
              // Navigation buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: const SizedBox(
                      width: 28,
                      height: 24,
                      child: Center(
                        child: Icon(
                          Icons.chevron_left,
                          color: Color(0xFF1E3A8A),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: const SizedBox(
                      width: 28,
                      height: 24,
                      child: Center(
                        child: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF1E3A8A),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0x4C3C3C43),
                          fontSize: 13,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w600,
                          height: 1.38,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...weeks.map((week) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: week.map((day) {
                    final isCurrentMonth =
                        day.month == _currentMonth.month;
                    final isSelected = _isSameDay(day, _selectedDate);
                    final hasEvent = _hasEventOnDate(day);
                    final isToday = _isSameDay(day, DateTime.now());

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = day;
                          });
                          widget.onDateSelected(day);
                        },
                        child: Container(
                          height: 51,
                          child: Stack(
                            children: [
                              if (isSelected && isCurrentMonth)
                                Positioned(
                                  left: 0,
                                  top: 4,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF1E3A8A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(22),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Center(
                                child: Text(
                                  day.day.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected && isCurrentMonth
                                        ? Colors.white
                                        : isCurrentMonth
                                            ? const Color(0xFF1E3A8A)
                                            : const Color(0xFF1E3A8A)
                                                .withOpacity(0.3),
                                    fontSize: isSelected && isCurrentMonth ? 24 : 20,
                                    fontFamily: 'SF Pro',
                                    fontWeight: isSelected && isCurrentMonth
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (hasEvent && isCurrentMonth && !isSelected)
                                Positioned(
                                  left: 16,
                                  top: 28,
                                  child: Container(
                                    width: 44.87,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }
}

