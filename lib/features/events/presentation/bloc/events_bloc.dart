import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_organizer_events.dart';
import '../../domain/usecases/get_upcoming_events.dart';

part 'events_event.dart';
part 'events_state.dart';

/// BLoC for managing events state.
@injectable
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetUpcomingEvents getUpcomingEvents;
  final GetOrganizerEvents getOrganizerEvents;

  EventsBloc(
    this.getUpcomingEvents,
    this.getOrganizerEvents,
  ) : super(const EventsInitial()) {
    on<FetchUpcomingEvents>(_onFetchUpcomingEvents);
    on<FetchOrganizerEvents>(_onFetchOrganizerEvents);
  }

  /// Listen to upcoming events stream and emit states accordingly.
  Future<void> _onFetchUpcomingEvents(
    FetchUpcomingEvents event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    await emit.forEach<Either<Failure, List<Event>>>(
      getUpcomingEvents(NoParams()),
      onData: (Either<Failure, List<Event>> result) {
        return result.fold(
          (failure) => EventsError(failure.message),
          (events) => EventsLoaded(events),
        );
      },
      onError: (error, stackTrace) {
        return EventsError('An unexpected error occurred: ${error.toString()}');
      },
    );
  }

  /// Listen to organizer events stream and emit states accordingly.
  Future<void> _onFetchOrganizerEvents(
    FetchOrganizerEvents event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    await emit.forEach<Either<Failure, List<Event>>>(
      getOrganizerEvents(event.orgId),
      onData: (Either<Failure, List<Event>> result) {
        return result.fold(
          (failure) => EventsError(failure.message),
          (events) => EventsLoaded(events),
        );
      },
      onError: (error, stackTrace) {
        return EventsError('An unexpected error occurred: ${error.toString()}');
      },
    );
  }
}
