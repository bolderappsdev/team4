import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../orders/presentation/pages/purchase_successful_page.dart';

/// Page displaying detailed event information for attendees.
class AttendeeEventDetailsPage extends StatefulWidget {
  final Event event;

  const AttendeeEventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<AttendeeEventDetailsPage> createState() =>
      _AttendeeEventDetailsPageState();
}

class _AttendeeEventDetailsPageState extends State<AttendeeEventDetailsPage> {
  String? _organizerName;
  String? _organizerDescription;
  String? _organizerPhotoUrl;
  bool _isLoadingOrganizer = true;
  bool _isProcessingPurchase = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizerInfo();
  }

  Future<void> _loadOrganizerInfo() async {
    try {
      // Fetch organization data
      final orgDoc = await FirebaseFirestore.instance
          .collection(AppConstants.organizationsCollection)
          .doc(widget.event.orgId)
          .get();

      if (orgDoc.exists) {
        final orgData = orgDoc.data()!;
        final ownerId = orgData['ownerId'] as String?;

        // Fetch owner user data
        if (ownerId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(ownerId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            setState(() {
              _organizerName = userData['displayName'] as String? ??
                  orgData['name'] as String? ??
                  'Organizer';
              _organizerDescription = userData['bio'] as String? ??
                  'Event organizer';
              _organizerPhotoUrl = userData['photoUrl'] as String?;
              _isLoadingOrganizer = false;
            });
            return;
          }
        }

        // Fallback to organization name
        setState(() {
          _organizerName = orgData['name'] as String? ?? 'Organizer';
          _organizerDescription = 'Event organizer';
          _isLoadingOrganizer = false;
        });
      } else {
        setState(() {
          _organizerName = 'Organizer';
          _organizerDescription = 'Event organizer';
          _isLoadingOrganizer = false;
        });
      }
    } catch (e) {
      setState(() {
        _organizerName = 'Organizer';
        _organizerDescription = 'Event organizer';
        _isLoadingOrganizer = false;
      });
    }
  }

  String _getImageUrl() {
    if (widget.event.imagePath != null &&
        widget.event.imagePath!.isNotEmpty) {
      // TODO: Get from Firebase Storage URL
      // For now, return placeholder
      return 'https://placehold.co/375x321';
    }
    return 'https://placehold.co/375x321';
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

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  String _formatPrice(int priceCents) {
    return '\$${(priceCents / 100).toStringAsFixed(0)}';
  }

  String _generateConfirmationCode() {
    // Generate a random 8-character alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _handleBuyTickets() async {
    if (_isProcessingPurchase) return;

    // Check if user is authenticated
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to purchase tickets'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = authState.user;
    final firstTicketType = widget.event.ticketTypes.isNotEmpty
        ? widget.event.ticketTypes.first
        : null;

    if (firstTicketType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tickets available for this event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPurchase = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Create order
      final confirmationCode = _generateConfirmationCode();
      final orderData = {
        'eventId': widget.event.id,
        'userId': user.id,
        'tickets': [
          {
            'ticketTypeId': firstTicketType.id,
            'qty': 1, // For MVP, we'll purchase 1 ticket
          }
        ],
        'amount_cents': firstTicketType.priceCents,
        'currency': 'USD',
        'paymentStatus': AppConstants.orderStatusPaid, // For MVP, mark as paid directly
        'paymentMethod': 'stripe_ui_placeholder',
        'stripeIntent': null,
        'confirmationCode': confirmationCode,
        'createdAt': Timestamp.fromDate(now),
      };

      final orderRef = await firestore
          .collection(AppConstants.ordersCollection)
          .add(orderData);

      // Create ticket
      final qrCodePayload = '${AppConstants.qrCodePrefix}${orderRef.id}';
      final ticketData = {
        'orderId': orderRef.id,
        'eventId': widget.event.id,
        'ownerUserId': user.id,
        'ticketTypeId': firstTicketType.id,
        'qrCodePayload': qrCodePayload,
        'checkedIn': false,
        'checkedInAt': null,
      };

      await firestore
          .collection(AppConstants.ticketsCollection)
          .add(ticketData);

      // Navigate to purchase successful page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PurchaseSuccessfulPage(
              event: widget.event,
              ticketCount: 1,
              confirmationCode: confirmationCode,
              userEmail: user.email,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error purchasing tickets: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPurchase = false;
        });
      }
    }
  }

  void _handleViewOnMap() {
    // TODO: Open map view or navigate to full map
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View on Map - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventType = widget.event.eventType;
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(widget.event.startAt);
    final endTime = timeFormat.format(widget.event.endAt);
    final firstTicketType = widget.event.ticketTypes.isNotEmpty
        ? widget.event.ticketTypes.first
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Event Image Section
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 321,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: _getImageUrl(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      // Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Type Badge and Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: ShapeDecoration(
                                color: _getBadgeColor(eventType),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: _getBadgeBorderColor(eventType),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                eventType,
                                style: TextStyle(
                                  color: _getBadgeTextColor(eventType),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.33,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.event.title,
                              style: const TextStyle(
                                color: Color(0xFF0F1728),
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Date and Time
                        Column(
                          children: [
                            // Date
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  padding: const EdgeInsets.all(8),
                                  decoration: ShapeDecoration(
                                    color: const Color(0x191E3A8A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                        ),
                                      ),
                                      Text(
                                        dateFormat.format(widget.event.startAt),
                                        style: const TextStyle(
                                          color: Color(0xFF0A0A0A),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                          letterSpacing: -0.31,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Time
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  padding: const EdgeInsets.all(8),
                                  decoration: ShapeDecoration(
                                    color: const Color(0x191E3A8A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                        ),
                                      ),
                                      Text(
                                        '$startTime - $endTime',
                                        style: const TextStyle(
                                          color: Color(0xFF0A0A0A),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                          letterSpacing: -0.31,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // About This Event
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About This Event',
                              style: TextStyle(
                                color: Color(0xFF0A0A0A),
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                                letterSpacing: -0.44,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.event.description,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.57,
                                letterSpacing: -0.31,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Location
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                color: Color(0xFF667084),
                                fontSize: 14,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w500,
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF6F6F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x0C101828),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 20,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.event.location.address,
                                      style: const TextStyle(
                                        color: Color(0xFF0B111D),
                                        fontSize: 14,
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w700,
                                        height: 1.43,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Map Preview
                        GestureDetector(
                          onTap: _handleViewOnMap,
                          child: Container(
                            width: double.infinity,
                            height: 152,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF2F3F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      widget.event.location.lat,
                                      widget.event.location.lng,
                                    ),
                                    zoom: 15,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(widget.event.id),
                                      position: LatLng(
                                        widget.event.location.lat,
                                        widget.event.location.lng,
                                      ),
                                    ),
                                  },
                                  mapType: MapType.normal,
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  scrollGesturesEnabled: false,
                                  zoomGesturesEnabled: false,
                                  onMapCreated: (controller) {
                                    // Map created
                                  },
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'View on Map',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Quicksand',
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Event Agenda
                        if (widget.event.agenda != null &&
                            widget.event.agenda!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Agenda',
                                style: TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  height: 1.50,
                                  letterSpacing: -0.44,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.event.agenda!
                                      .map((agendaItem) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin: const EdgeInsets.only(
                                                    top: 8,
                                                    right: 12,
                                                  ),
                                                  decoration: const ShapeDecoration(
                                                    color: Color(0xFF1E3A8A),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(4),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    agendaItem,
                                                    style: const TextStyle(
                                                      color: Color(0xFF6B7280),
                                                      fontSize: 16,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.50,
                                                      letterSpacing: -0.31,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        if (widget.event.agenda != null &&
                            widget.event.agenda!.isNotEmpty)
                          const SizedBox(height: 24),
                        // Organizer
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Organizer',
                              style: TextStyle(
                                color: Color(0xFF0A0A0A),
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                                letterSpacing: -0.44,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(32),
                                      ),
                                    ),
                                  ),
                                  child: _organizerPhotoUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: _organizerPhotoUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.person),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            size: 32,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _organizerName ?? 'Organizer',
                                        style: const TextStyle(
                                          color: Color(0xFF0A0A0A),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          height: 1.50,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _organizerDescription ??
                                            'Event organizer',
                                        style: const TextStyle(
                                          color: Color(0xFF495565),
                                          fontSize: 14,
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 1.43,
                                          letterSpacing: -0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0F1728),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Ticket Section
      bottomNavigationBar: firstTicketType != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: Color(0xFFEAECF0),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ticket Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Get Your Ticket',
                                style: TextStyle(
                                  color: Color(0xFF0A0A0A),
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                  letterSpacing: -0.44,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                firstTicketType.title,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: -0.31,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatPrice(firstTicketType.priceCents),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 30,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                                letterSpacing: 0.40,
                              ),
                            ),
                            const Text(
                              'per person',
                              textAlign: TextAlign.right,
                              style: TextStyle(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Buy Tickets Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessingPurchase ? null : _handleBuyTickets,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      child: _isProcessingPurchase
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Buy Tickets',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w600,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )
          : null,
    );
  }
}

