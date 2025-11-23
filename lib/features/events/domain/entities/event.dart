import 'package:equatable/equatable.dart';

/// Location data for an event.
class EventLocation extends Equatable {
  final double lat;
  final double lng;
  final String address;

  const EventLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  @override
  List<Object?> get props => [lat, lng, address];
}

/// Ticket type for an event.
class TicketType extends Equatable {
  final String id;
  final String title;
  final int priceCents;
  final int quantity;
  final DateTime? salesStart;
  final DateTime? salesEnd;

  const TicketType({
    required this.id,
    required this.title,
    required this.priceCents,
    required this.quantity,
    this.salesStart,
    this.salesEnd,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        priceCents,
        quantity,
        salesStart,
        salesEnd,
      ];
}

/// Event entity representing a political event in the domain layer.
///
/// This is a pure business object with no dependencies on external frameworks.
class Event extends Equatable {
  final String id;
  final String orgId;
  final String title;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final EventLocation location;
  final int capacity;
  final List<TicketType> ticketTypes;
  final String? imagePath;
  final String status; // pending, approved, published, cancelled
  final List<String>? agenda; // Optional list of agenda items
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.orgId,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.capacity,
    required this.ticketTypes,
    this.imagePath,
    required this.status,
    this.agenda,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if event is published.
  bool get isPublished => status == 'published';

  /// Check if event is upcoming.
  bool get isUpcoming => startAt.isAfter(DateTime.now());

  /// Get event type/category based on title or description.
  /// This is a simple heuristic - in production this would come from the event data.
  String get eventType {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('town hall')) {
      return 'Town Hall';
    } else if (lowerTitle.contains('rally')) {
      return 'Forum';
    } else if (lowerTitle.contains('debate')) {
      return 'Debate';
    } else if (lowerTitle.contains('forum')) {
      return 'Forum';
    }
    return 'Event';
  }

  @override
  List<Object?> get props => [
        id,
        orgId,
        title,
        description,
        startAt,
        endAt,
        location,
        capacity,
        ticketTypes,
        imagePath,
        status,
        agenda,
        createdAt,
        updatedAt,
      ];
}
