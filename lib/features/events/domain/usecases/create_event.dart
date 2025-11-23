import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Parameters for creating an event.
class CreateEventParams extends Equatable {
  final Event event;

  const CreateEventParams({required this.event});

  @override
  List<Object?> get props => [event];
}

/// Use case for creating a new event.
@injectable
class CreateEvent implements UseCase<Event, CreateEventParams> {
  final EventRepository repository;

  CreateEvent(this.repository);

  @override
  Future<Either<Failure, Event>> call(CreateEventParams params) async {
    return await repository.createEvent(params.event);
  }
}

