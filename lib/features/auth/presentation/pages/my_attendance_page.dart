import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../events/domain/entities/event.dart';
import '../../../events/domain/repositories/event_repository.dart';
import '../../../events/presentation/pages/attendee_event_details_page.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/constants.dart';
import '../widgets/attendance_calendar_widget.dart';

/// My Attendance page showing events the user is attending with calendar view.
class MyAttendancePage extends StatefulWidget {
  const MyAttendancePage({super.key});

  @override
  State<MyAttendancePage> createState() => _MyAttendancePageState();
}

class _MyAttendancePageState extends State<MyAttendancePage> {
  DateTime _selectedDate = DateTime.now();
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _eventsSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  void _loadEvents(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      setState(() {
        _error = 'User not authenticated';
        _isLoading = false;
      });
      return;
    }

    try {
      final userId = authState.user.id;
      final eventRepository = getIt<EventRepository>();

      setState(() {
        _isLoading = true;
        _error = null;
      });

      _eventsSubscription?.cancel();
      _eventsSubscription = eventRepository.getEventsByUserAttendance(userId).listen(
        (result) {
          if (!mounted) return;
          result.fold(
            (failure) {
              setState(() {
                _error = _getErrorMessage(failure);
                _isLoading = false;
              });
            },
            (events) {
              setState(() {
                _allEvents = events;
                _filterEventsByDate(_selectedDate);
                _isLoading = false;
              });
            },
          );
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    }
    return 'An unexpected error occurred';
  }

  void _filterEventsByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filteredEvents = _allEvents.where((event) {
        final eventDate = DateTime(
          event.startAt.year,
          event.startAt.month,
          event.startAt.day,
        );
        final selectedDateOnly = DateTime(
          date.year,
          date.month,
          date.day,
        );
        return eventDate.year == selectedDateOnly.year &&
            eventDate.month == selectedDateOnly.month &&
            eventDate.day == selectedDateOnly.day;
      }).toList();
    });
  }

  List<DateTime> _getEventDates() {
    return _allEvents.map((event) {
      return DateTime(
        event.startAt.year,
        event.startAt.month,
        event.startAt.day,
      );
    }).toList();
  }

  String _getImageUrl(Event event) {
    if (event.imagePath != null && event.imagePath!.isNotEmpty) {
      // TODO: Get from Firebase Storage URL
      return 'https://placehold.co/341x192';
    }
    return 'https://placehold.co/341x192';
  }

  Color _getBadgeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFFDBEAFE);
      case 'forum':
        return const Color(0xFFFFEDD4);
      case 'debate':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  Color _getBadgeBorderColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFFBDDAFF);
      case 'forum':
        return const Color(0xFFFFD6A7);
      case 'debate':
        return const Color(0xFFE9D4FF);
      default:
        return const Color(0xFFBDDAFF);
    }
  }

  Color _getBadgeTextColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFF193BB8);
      case 'forum':
        return const Color(0xFF9F2D00);
      case 'debate':
        return const Color(0xFF6D10B0);
      default:
        return const Color(0xFF193BB8);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return const Color(0xFFDCFCE7);
      case 'pending':
        return const Color(0xFFFEF3C6);
      case 'cancelled':
        return const Color(0xFFFFE2E2);
      default:
        return const Color(0xFFDCFCE7);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return const Color(0xFF016630);
      case 'pending':
        return const Color(0xFF963B00);
      case 'cancelled':
        return const Color(0xFF9E0711);
      default:
        return const Color(0xFF016630);
    }
  }

  String _getEventStatus(Event event) {
    final now = DateTime.now();
    if (event.status == 'cancelled') {
      return 'Cancelled';
    }
    if (event.startAt.isAfter(now)) {
      return 'Upcoming';
    }
    if (event.startAt.isBefore(now) && event.endAt.isAfter(now)) {
      return 'Ongoing';
    }
    return 'Pending';
  }

  Future<String> _getOrganizerName(String orgId) async {
    try {
      final orgDoc = await FirebaseFirestore.instance
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .get();

      if (orgDoc.exists) {
        final orgData = orgDoc.data()!;
        final ownerId = orgData['ownerId'] as String?;

        if (ownerId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(ownerId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            return userData['displayName'] as String? ??
                orgData['name'] as String? ??
                'Organizer';
          }
        }

        return orgData['name'] as String? ?? 'Organizer';
      }
    } catch (e) {
      // Error loading organizer
    }
    return 'Organizer';
  }

  @override
  Widget build(BuildContext context) {
    // Load events when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_allEvents.isEmpty && _isLoading) {
        _loadEvents(context);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Events',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F1728),
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search Bar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF6F6F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 16,
                              color: Color(0xFF667084),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Search',
                              style: TextStyle(
                                color: Color(0xFF667084),
                                fontSize: 14,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Calendar Widget
                        AttendanceCalendarWidget(
                          selectedDate: _selectedDate,
                          eventDates: _getEventDates(),
                          onDateSelected: _filterEventsByDate,
                        ),
                        const SizedBox(height: 12),
                        // Events List
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_error != null)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFF0F1728),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _loadEvents(context),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else if (_filteredEvents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_available,
                                  size: 64,
                                  color: Color(0xFF667084),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No events on this date',
                                  style: TextStyle(
                                    color: Color(0xFF0F1728),
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._filteredEvents.map((event) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _EventCard(
                                  event: event,
                                  onViewDetails: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AttendeeEventDetailsPage(
                                          event: event,
                                        ),
                                      ),
                                    );
                                  },
                                  getImageUrl: _getImageUrl,
                                  getBadgeColor: _getBadgeColor,
                                  getBadgeBorderColor: _getBadgeBorderColor,
                                  getBadgeTextColor: _getBadgeTextColor,
                                  getStatusColor: _getStatusColor,
                                  getStatusTextColor: _getStatusTextColor,
                                  getEventStatus: _getEventStatus,
                                  getOrganizerName: _getOrganizerName,
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Event card widget for attendance page.
class _EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onViewDetails;
  final String Function(Event) getImageUrl;
  final Color Function(String) getBadgeColor;
  final Color Function(String) getBadgeBorderColor;
  final Color Function(String) getBadgeTextColor;
  final Color Function(String) getStatusColor;
  final Color Function(String) getStatusTextColor;
  final String Function(Event) getEventStatus;
  final Future<String> Function(String) getOrganizerName;

  const _EventCard({
    required this.event,
    required this.onViewDetails,
    required this.getImageUrl,
    required this.getBadgeColor,
    required this.getBadgeBorderColor,
    required this.getBadgeTextColor,
    required this.getStatusColor,
    required this.getStatusTextColor,
    required this.getEventStatus,
    required this.getOrganizerName,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  String _organizerName = 'Loading...';
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _loadOrganizerName();
  }

  Future<void> _loadOrganizerName() async {
    final name = await widget.getOrganizerName(widget.event.orgId);
    if (mounted) {
      setState(() {
        _organizerName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventType = widget.event.eventType;
    final status = widget.getEventStatus(widget.event);
    final startDate = _dateFormat.format(widget.event.startAt);
    final startTime = _timeFormat.format(widget.event.startAt);
    final endTime = _timeFormat.format(widget.event.endAt);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFCFD4DC),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            width: double.infinity,
            height: 192,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.getImageUrl(widget.event),
                  width: double.infinity,
                  height: 192,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF6F6F6),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF6F6F6),
                    child: const Icon(Icons.error),
                  ),
                ),
                // Event Type Badge
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: widget.getBadgeColor(eventType),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: widget.getBadgeBorderColor(eventType),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      eventType,
                      style: TextStyle(
                        color: widget.getBadgeTextColor(eventType),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: widget.getStatusColor(status),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: widget.getStatusTextColor(status),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Event Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title
                Text(
                  widget.event.title,
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: -0.31,
                  ),
                ),
                const SizedBox(height: 12),
                // Event Info
                Column(
                  children: [
                    // Date
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          startDate,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Time
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$startTime - $endTime',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Organizer
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _organizerName,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              letterSpacing: -0.15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.event.location.address,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                              letterSpacing: -0.15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // View Details Button
                GestureDetector(
                  onTap: widget.onViewDetails,
                  child: Container(
                    width: double.infinity,
                    height: 36,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'View Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.43,
                            letterSpacing: -0.15,
                          ),
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
    );
  }
}
