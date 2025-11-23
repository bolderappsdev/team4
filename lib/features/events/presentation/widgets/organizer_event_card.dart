import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';

/// Widget for displaying an event card in the organizer home page.
/// Shows event details with status badges, registration progress, and action buttons.
class OrganizerEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OrganizerEventCard({
    super.key,
    required this.event,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  /// Get badge color based on event type.
  Color _getEventTypeBadgeColor(String eventType) {
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

  /// Get badge border color based on event type.
  Color _getEventTypeBadgeBorderColor(String eventType) {
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

  /// Get badge text color based on event type.
  Color _getEventTypeBadgeTextColor(String eventType) {
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

  /// Get status badge color based on event status.
  Color _getStatusBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'published':
        return const Color(0xFFDCFCE7);
      case 'pending':
        return const Color(0xFFFEF3C6);
      case 'cancelled':
        return const Color(0xFFFFE2E2);
      default:
        return const Color(0xFFFEF3C6);
    }
  }

  /// Get status badge text color.
  Color _getStatusBadgeTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'published':
        return const Color(0xFF016630);
      case 'pending':
        return const Color(0xFF963B00);
      case 'cancelled':
        return const Color(0xFF9E0711);
      default:
        return const Color(0xFF963B00);
    }
  }

  /// Get status display text.
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'published':
        return 'Approved';
      case 'pending':
        return 'Pending Approval';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Get image URL for event.
  String _getImageUrl() {
    if (event.imagePath != null && event.imagePath!.isNotEmpty) {
      // TODO: Get from Firebase Storage URL
      // For now, return placeholder
      return 'https://placehold.co/341x192';
    }
    return 'https://placehold.co/341x192';
  }

  /// Calculate registration progress.
  /// TODO: Replace with actual registration count from orders/tickets
  int _getRegistrationCount() {
    // Placeholder: calculate based on capacity
    // In production, this would come from orders/tickets collection
    return (event.capacity * 0.6).round(); // Simulated 60% registration
  }

  double _getRegistrationPercentage() {
    if (event.capacity == 0) return 0.0;
    final registered = _getRegistrationCount();
    return (registered / event.capacity).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final eventType = event.eventType;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final registeredCount = _getRegistrationCount();
    final registrationPercentage = _getRegistrationPercentage();

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image with Badges
          Container(
            width: double.infinity,
            height: 192,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: _getImageUrl(),
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
                      color: _getEventTypeBadgeColor(eventType),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: _getEventTypeBadgeBorderColor(eventType),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      eventType,
                      style: TextStyle(
                        color: _getEventTypeBadgeTextColor(eventType),
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
                      color: _getStatusBadgeColor(event.status),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Colors.black.withOpacity(0),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _getStatusText(event.status),
                      style: TextStyle(
                        color: _getStatusBadgeTextColor(event.status),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title
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
                // Date and Location
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        Text(
                          '${dateFormat.format(event.startAt)} at ${timeFormat.format(event.startAt)}',
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
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Registration Progress
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 9),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Color(0xFFF0F4F9),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Registration Count and Percentage
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: Icon(
                                  Icons.people,
                                  size: 16,
                                  color: Color(0xFF45556C),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$registeredCount/${event.capacity}',
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
                          Text(
                            '${(registrationPercentage * 100).round()}%',
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
                      const SizedBox(height: 8),
                      // Progress Bar
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(33554428),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: registrationPercentage,
                          child: Container(
                            height: 6,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1B388E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(33554428),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // View Button
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.visibility_outlined,
                        label: 'View',
                        onTap: onView,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit Button
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Button
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: '',
                      onTap: onDelete,
                      isIconOnly: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget for organizer event card.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isIconOnly;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: isIconOnly ? 36 : null,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFCAD5E2),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isIconOnly
            ? Center(
                child: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF0A0A0A),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: const Color(0xFF0A0A0A),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0A0A0A),
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
    );
  }
}

