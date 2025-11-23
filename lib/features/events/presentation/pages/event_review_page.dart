import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/auth/presentation/pages/organizer_home_page.dart';
import 'package:leadright/features/events/presentation/bloc/events_bloc.dart';
import 'package:leadright/features/events/presentation/models/event_creation_data.dart';

/// Fourth page in the event creation process (4/4).
/// Displays event review and allows creation of the event.
class EventReviewPage extends StatefulWidget {
  final EventCreationData eventData;

  const EventReviewPage({
    super.key,
    required this.eventData,
  });

  @override
  State<EventReviewPage> createState() => _EventReviewPageState();
}

class _EventReviewPageState extends State<EventReviewPage> {
  @override
  void initState() {
    super.initState();
  }

  void _handleCreate() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final orgId = authState.user.organizationId;
      if (orgId == null || orgId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No organization found. Please complete your profile.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Convert EventCreationData to Event entity
      final event = widget.eventData.toEvent(
        orgId: orgId,
        imagePath: null, // TODO: Upload image and get URL
      );

      // Dispatch create event
      context.read<EventsBloc>().add(CreateEventRequested(event));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progressWidth = screenWidth; // 4/4 = 100%

    return BlocProvider(
      create: (context) => getIt<EventsBloc>(),
      child: BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {
        if (state is EventCreated) {
          // Navigate to organizer home page
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const OrganizerHomePage(),
            ),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is EventsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating event: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
                            'Review',
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
                            '4/4',
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
                              width: progressWidth,
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
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Admin Approval Notice
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFFFBEB),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFFDE585),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF7A3206),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Admin Approval Required',
                                    style: TextStyle(
                                      color: Color(0xFF7A3206),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.43,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Your event will be reviewed by our team before going live. This typically takes 24-48 hours. You\'ll receive an email notification once your event is approved.',
                                    style: TextStyle(
                                      color: Color(0xFF7A3206),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.62,
                                      letterSpacing: -0.15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Event Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.antiAlias,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Image
                            Container(
                              width: double.infinity,
                              height: 256,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                image: widget.eventData.coverImage != null
                                    ? DecorationImage(
                                        image: FileImage(widget.eventData.coverImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: widget.eventData.coverImage == null
                                  ? const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: Color(0xFF61738D),
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        Positioned(
                                          left: 16,
                                          top: 19,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFF1B388E),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              widget.eventData.theme.toLowerCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
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
                                  // Title and Description
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.eventData.title,
                                        style: const TextStyle(
                                          color: Color(0xFF0E162B),
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                          letterSpacing: -0.45,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          widget.eventData.description,
                                          style: const TextStyle(
                                            color: Color(0xFF45556C),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.50,
                                            letterSpacing: -0.31,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Date & Time
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Color(0xFF45556C),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Date & Time',
                                              style: TextStyle(
                                                color: Color(0xFF0E162B),
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 1.43,
                                                letterSpacing: -0.15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('EEEE, MMMM d, yyyy, h:mm a')
                                                  .format(widget.eventData.startAt),
                                              style: const TextStyle(
                                                color: Color(0xFF45556C),
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
                                  const SizedBox(height: 24),
                                  // Location
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Color(0xFF45556C),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Location',
                                              style: TextStyle(
                                                color: Color(0xFF0E162B),
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                                height: 1.43,
                                                letterSpacing: -0.15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.eventData.location,
                                              style: const TextStyle(
                                                color: Color(0xFF45556C),
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
                                  const SizedBox(height: 24),
                                  // Ticket Types
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ticket Types',
                                        style: TextStyle(
                                          color: Color(0xFF0E162B),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.50,
                                          letterSpacing: -0.31,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: ShapeDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment(0.00, 0.00),
                                            end: Alignment(1.00, 1.00),
                                            colors: [Color(0xFFEEF5FE), Color(0xFFF8F9FB)],
                                          ),
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              width: 1,
                                              color: Color(0xFFDAEAFE),
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF1B388E),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.confirmation_number,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.eventData.ticketName,
                                                      style: const TextStyle(
                                                        color: Color(0xFF0E162B),
                                                        fontSize: 16,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.50,
                                                        letterSpacing: -0.31,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${widget.eventData.availability} available',
                                                      style: const TextStyle(
                                                        color: Color(0xFF45556C),
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
                                            Text(
                                              '\$${widget.eventData.price.toStringAsFixed(2)}',
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Color(0xFF1B388E),
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
                                  const SizedBox(height: 24),
                                  // Event Summary
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFDAEAFE),
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Event Summary',
                                          style: TextStyle(
                                            color: Color(0xFF1B388E),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            height: 1.50,
                                            letterSpacing: -0.31,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Total Capacity',
                                                    style: TextStyle(
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
                                                    '${widget.eventData.availability} tickets',
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
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Potential Revenue',
                                                    style: TextStyle(
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
                                                    '\$${(widget.eventData.price * widget.eventData.availability).toStringAsFixed(2)}',
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
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Theme',
                                                    style: TextStyle(
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
                                                    widget.eventData.theme.toLowerCase(),
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
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Media',
                                                    style: TextStyle(
                                                      color: Color(0xFF45556C),
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.43,
                                                      letterSpacing: -0.15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.image,
                                                        size: 16,
                                                        color: Color(0xFF0E162B),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        widget.eventData.coverImage != null
                                                            ? 'Cover'
                                                            : 'No image',
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Button Section
              BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  final isLoading = state is EventCreating;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleCreate,
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
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create',
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

