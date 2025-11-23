import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/event.dart';

/// Repository interface for events operations.
///
/// This interface is defined in the domain layer and implemented
/// in the data layer, following Clean Architecture principles.
abstract class EventRepository {
  /// Get upcoming published events.
  Stream<Either<Failure, List<Event>>> getUpcomingEvents();

  /// Get event by ID.
  Future<Either<Failure, Event>> getEventById(String eventId);

  /// Get events by organization ID.
  Stream<Either<Failure, List<Event>>> getEventsByOrganization(String orgId);

  /// Create a new event.
  Future<Either<Failure, Event>> createEvent(Event event);

  /// Get events that a user is attending (via tickets).
  Stream<Either<Failure, List<Event>>> getEventsByUserAttendance(String userId);
}
