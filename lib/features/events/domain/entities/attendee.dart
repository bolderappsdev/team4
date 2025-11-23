import 'package:equatable/equatable.dart';

/// Attendee entity representing a registered attendee for an event.
class Attendee extends Equatable {
  final String id;
  final String ticketId;
  final String eventId;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String email;
  final String ticketTypeId;
  final String ticketTypeTitle;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final DateTime registeredAt;

  const Attendee({
    required this.id,
    required this.ticketId,
    required this.eventId,
    required this.userId,
    this.firstName,
    this.lastName,
    required this.email,
    required this.ticketTypeId,
    required this.ticketTypeTitle,
    required this.checkedIn,
    this.checkedInAt,
    required this.registeredAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email.split('@').first;
  }

  @override
  List<Object?> get props => [
        id,
        ticketId,
        eventId,
        userId,
        firstName,
        lastName,
        email,
        ticketTypeId,
        ticketTypeTitle,
        checkedIn,
        checkedInAt,
        registeredAt,
      ];
}

