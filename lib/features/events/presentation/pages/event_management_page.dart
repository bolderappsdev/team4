import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadright/core/utils/constants.dart';
import 'package:leadright/features/events/domain/entities/attendee.dart';
import 'package:leadright/features/events/domain/entities/event.dart';

/// Event Management page for organizers to view event details, statistics, and manage attendees.
class EventManagementPage extends StatefulWidget {
  final Event event;

  const EventManagementPage({
    super.key,
    required this.event,
  });

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  List<Attendee> _attendees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAttendees();
  }

  Future<void> _fetchAttendees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Fetch all tickets for this event
      final ticketsSnapshot = await firestore
          .collection(AppConstants.ticketsCollection)
          .where('eventId', isEqualTo: widget.event.id)
          .get();

      final attendees = <Attendee>[];
      
      // Fetch user data for each ticket
      for (final ticketDoc in ticketsSnapshot.docs) {
        final ticketData = ticketDoc.data();
        final userId = ticketData['ownerUserId'] as String?;
        
        if (userId == null) continue;

        // Fetch user data
        final userDoc = await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .get();

        if (!userDoc.exists) continue;

        final userData = userDoc.data()!;
        
        // Get ticket type title
        final ticketTypeId = ticketData['ticketTypeId'] as String? ?? '';
        final ticketTypeTitle = _getTicketTypeTitle(ticketTypeId);
        
        // Get registration date from order
        final orderId = ticketData['orderId'] as String?;
        DateTime registeredAt = DateTime.now();
        if (orderId != null) {
          final orderDoc = await firestore
              .collection(AppConstants.ordersCollection)
              .doc(orderId)
              .get();
          if (orderDoc.exists) {
            final orderData = orderDoc.data()!;
            final createdAt = orderData['createdAt'];
            if (createdAt is Timestamp) {
              registeredAt = createdAt.toDate();
            }
          }
        }

        final attendee = Attendee(
          id: ticketDoc.id,
          ticketId: ticketDoc.id,
          eventId: widget.event.id,
          userId: userId,
          firstName: userData['displayName']?.toString().split(' ').first,
          lastName: userData['displayName']!.toString().split(' ').length > 1
              ? userData['displayName']?.toString().split(' ').skip(1).join(' ')
              : null,
          email: userData['email'] as String? ?? '',
          ticketTypeId: ticketTypeId,
          ticketTypeTitle: ticketTypeTitle,
          checkedIn: ticketData['checkedIn'] as bool? ?? false,
          checkedInAt: ticketData['checkedInAt'] is Timestamp
              ? (ticketData['checkedInAt'] as Timestamp).toDate()
              : null,
          registeredAt: registeredAt,
        );

        attendees.add(attendee);
      }

      setState(() {
        _attendees = attendees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load attendees: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getTicketTypeTitle(String ticketTypeId) {
    for (final ticketType in widget.event.ticketTypes) {
      if (ticketType.id == ticketTypeId) {
        return ticketType.title;
      }
    }
    return 'General Admission';
  }

  int get _totalRegistered => _attendees.length;
  int get _checkedIn => _attendees.where((a) => a.checkedIn).length;
  int get _notCheckedIn => _totalRegistered - _checkedIn;
  double get _attendanceRate => _totalRegistered > 0 
      ? (_checkedIn / _totalRegistered) * 100 
      : 0.0;

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getStatusBadgeText() {
    final status = widget.event.status.toLowerCase();
    if (status == 'approved' || status == 'published') {
      return 'Approved';
    } else if (status == 'pending') {
      return 'Pending';
    } else if (status == 'cancelled') {
      return 'Cancelled';
    }
    return 'Unknown';
  }

  Color _getStatusBadgeColor() {
    final status = widget.event.status.toLowerCase();
    if (status == 'approved' || status == 'published') {
      return const Color(0xFF016630);
    } else if (status == 'pending') {
      return const Color(0xFFF59E0B);
    } else if (status == 'cancelled') {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF667084);
  }

  Color _getStatusBadgeBgColor() {
    final status = widget.event.status.toLowerCase();
    if (status == 'approved' || status == 'published') {
      return const Color(0xFFDCFCE7);
    } else if (status == 'pending') {
      return const Color(0xFFFEF3C7);
    } else if (status == 'cancelled') {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFF6F6F6);
  }

  void _showAttendeeDetails(Attendee attendee) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => _AttendeeDetailsBottomSheet(attendee: attendee),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _HeaderSection(
              onBack: () => Navigator.of(context).pop(),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchAttendees,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event Card
                              _EventCard(
                                event: widget.event,
                                statusBadgeText: _getStatusBadgeText(),
                                statusBadgeColor: _getStatusBadgeColor(),
                                statusBadgeBgColor: _getStatusBadgeBgColor(),
                                formatDateTime: _formatDateTime,
                              ),
                              const SizedBox(height: 24),
                              // Statistics Cards
                              _StatisticsSection(
                                totalRegistered: _totalRegistered,
                                checkedIn: _checkedIn,
                                notCheckedIn: _notCheckedIn,
                                attendanceRate: _attendanceRate,
                              ),
                              const SizedBox(height: 24),
                              // Attendees List
                              _AttendeesSection(
                                attendees: _attendees,
                                formatDate: _formatDateShort,
                                onAttendeeTap: _showAttendeeDetails,
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header section with back button and title.
class _HeaderSection extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderSection({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
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
              onPressed: onBack,
            ),
          ),
          const Expanded(
            child: Text(
              'Attendee Management',
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
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

/// Event card showing event details.
class _EventCard extends StatelessWidget {
  final Event event;
  final String statusBadgeText;
  final Color statusBadgeColor;
  final Color statusBadgeBgColor;
  final String Function(DateTime) formatDateTime;

  const _EventCard({
    required this.event,
    required this.statusBadgeText,
    required this.statusBadgeColor,
    required this.statusBadgeBgColor,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFCFD4DC)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            width: 108,
            height: 141,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                if (event.imagePath != null)
                  Image.network(
                    event.imagePath!,
                    width: 108,
                    height: 141,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.event,
                          size: 48,
                          color: Color(0xFF667084),
                        ),
                      );
                    },
                  )
                else
                  const Center(
                    child: Icon(
                      Icons.event,
                      size: 48,
                      color: Color(0xFF667084),
                    ),
                  ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: ShapeDecoration(
                      color: statusBadgeBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      statusBadgeText,
                      style: TextStyle(
                        color: statusBadgeColor,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
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
                  // Date
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF45556C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formatDateTime(event.startAt),
                          style: const TextStyle(
                            color: Color(0xFF45556C),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            letterSpacing: -0.15,
                          ),
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
                          color: Color(0xFF45556C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location.address,
                          style: const TextStyle(
                            color: Color(0xFF45556C),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics section showing event metrics.
class _StatisticsSection extends StatelessWidget {
  final int totalRegistered;
  final int checkedIn;
  final int notCheckedIn;
  final double attendanceRate;

  const _StatisticsSection({
    required this.totalRegistered,
    required this.checkedIn,
    required this.notCheckedIn,
    required this.attendanceRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatCard(
          label: 'Total Registered',
          value: totalRegistered.toString(),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Checked In',
          value: checkedIn.toString(),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Not Checked In',
          value: notCheckedIn.toString(),
        ),
        const SizedBox(height: 12),
        _StatCard(
          label: 'Attendance Rate',
          value: '${attendanceRate.toStringAsFixed(0)}%',
          showProgress: true,
          progressValue: attendanceRate,
        ),
      ],
    );
  }
}

/// Individual statistics card.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool showProgress;
  final double progressValue;

  const _StatCard({
    required this.label,
    required this.value,
    this.showProgress = false,
    this.progressValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFEAECF0)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF45556C),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0E162B),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                  letterSpacing: -0.31,
                ),
              ),
            ],
          ),
          if (showProgress)
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.only(right: 0.02),
              decoration: ShapeDecoration(
                color: const Color(0xFFDCFCE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(33554428),
                ),
              ),
              child: Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0D532B),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

/// Attendees list section.
class _AttendeesSection extends StatelessWidget {
  final List<Attendee> attendees;
  final String Function(DateTime) formatDate;
  final Function(Attendee) onAttendeeTap;

  const _AttendeesSection({
    required this.attendees,
    required this.formatDate,
    required this.onAttendeeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendees (${attendees.length})',
          style: const TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: -0.31,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE1E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 40,
                decoration: const ShapeDecoration(
                  color: Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Color(0x1A000000),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _TableHeaderCell(
                      width: 172,
                      text: 'First Name',
                    ),
                    _TableHeaderCell(
                      width: 169,
                      text: 'Last Name',
                    ),
                    _TableHeaderCell(
                      width: 75,
                      text: 'Check-in',
                    ),
                  ],
                ),
              ),
              // Rows
              ...attendees.map((attendee) {
                return _AttendeeRow(
                  attendee: attendee,
                  formatDate: formatDate,
                  onTap: () => onAttendeeTap(attendee),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

/// Table header cell.
class _TableHeaderCell extends StatelessWidget {
  final double width;
  final String text;

  const _TableHeaderCell({
    required this.width,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.only(left: 8, top: 9.75),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0A0A0A),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: -0.15,
        ),
      ),
    );
  }
}

/// Attendee table row.
class _AttendeeRow extends StatelessWidget {
  final Attendee attendee;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _AttendeeRow({
    required this.attendee,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 39,
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Color(0x1A000000),
            ),
          ),
        ),
        child: Row(
          children: [
            _TableCell(
              width: 172,
              text: attendee.firstName ?? '',
            ),
            _TableCell(
              width: 169,
              text: attendee.lastName ?? '',
            ),
            Container(
              width: 75,
              height: 39,
              padding: const EdgeInsets.only(left: 8, top: 11.50),
              child: Container(
                width: 16,
                height: 16,
                decoration: ShapeDecoration(
                  color: attendee.checkedIn
                      ? const Color(0xFF030213)
                      : const Color(0xFFF3F3F5),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: attendee.checkedIn
                          ? const Color(0xFF030213)
                          : Colors.black.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  shadows: [
                    BoxShadow(
                      color: const Color(0x0C000000),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: attendee.checkedIn
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Table cell.
class _TableCell extends StatelessWidget {
  final double width;
  final String text;

  const _TableCell({
    required this.width,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 39,
      padding: const EdgeInsets.only(left: 8, top: 9.50),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0A0A0A),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: -0.15,
        ),
      ),
    );
  }
}

/// Bottom sheet showing attendee details.
class _AttendeeDetailsBottomSheet extends StatelessWidget {
  final Attendee attendee;

  const _AttendeeDetailsBottomSheet({required this.attendee});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 50,
            height: 4,
            decoration: ShapeDecoration(
              color: const Color(0xFFEAECF0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(55),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          const Text(
            'Attendee Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.56,
            ),
          ),
          const SizedBox(height: 24),
          // Details
          Column(
            children: [
              // First Name and Last Name
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF6F6F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'First Name',
                            style: TextStyle(
                              color: Color(0xFF0F1728),
                              fontSize: 16,
                              fontFamily: 'Futura PT',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            attendee.firstName ?? '',
                            style: const TextStyle(
                              color: Color(0xFF667084),
                              fontSize: 14,
                              fontFamily: 'Futura PT',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF6F6F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Last Name',
                            style: TextStyle(
                              color: Color(0xFF0F1728),
                              fontSize: 16,
                              fontFamily: 'Futura PT',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            attendee.lastName ?? '',
                            style: const TextStyle(
                              color: Color(0xFF667084),
                              fontSize: 14,
                              fontFamily: 'Futura PT',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Ticket Type and Status
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF6F6F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ticket Type',
                            style: TextStyle(
                              color: Color(0xFF0F1728),
                              fontSize: 16,
                              fontFamily: 'Futura PT',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFDBEAFE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              attendee.ticketTypeTitle,
                              style: const TextStyle(
                                color: Color(0xFF1B388E),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF6F6F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              color: Color(0xFF0F1728),
                              fontSize: 16,
                              fontFamily: 'Futura PT',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: ShapeDecoration(
                              color: attendee.checkedIn
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF3F3F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              attendee.checkedIn ? 'Checked In' : 'Not Checked In',
                              style: TextStyle(
                                color: attendee.checkedIn
                                    ? const Color(0xFF016630)
                                    : const Color(0xFF667084),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.33,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Close Button
          Container(
            width: 343,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Center(
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF344053),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

