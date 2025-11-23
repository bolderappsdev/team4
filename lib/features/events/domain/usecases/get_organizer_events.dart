import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Use case for getting events by organization ID.
@injectable
class GetOrganizerEvents implements StreamUseCase<List<Event>, String> {
  final EventRepository repository;

  GetOrganizerEvents(this.repository);

  @override
  Stream<Either<Failure, List<Event>>> call(String orgId) {
    return repository.getEventsByOrganization(orgId);
  }
}

