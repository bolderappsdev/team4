part of 'events_bloc.dart';

/// Base class for all events-related events.
abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch upcoming events.
class FetchUpcomingEvents extends EventsEvent {
  const FetchUpcomingEvents();
}

/// Event to fetch organizer events by organization ID.
class FetchOrganizerEvents extends EventsEvent {
  final String orgId;

  const FetchOrganizerEvents(this.orgId);

  @override
  List<Object?> get props => [orgId];
}
