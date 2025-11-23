import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

@LazySingleton(as: EventRepository)
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EventRepositoryImpl(
    this.remoteDataSource,
    this.networkInfo,
  );

  @override
  Stream<Either<Failure, List<Event>>> getUpcomingEvents() {
    return remoteDataSource.getUpcomingEvents().transform(
      StreamTransformer<List<EventModel>, Either<Failure, List<Event>>>.fromHandlers(
        handleData: (eventModels, sink) {
          try {
            final events = eventModels.map((model) => model.toEntity()).toList();
            sink.add(Right(events));
          } catch (e) {
            sink.add(
              Left<Failure, List<Event>>(
                ServerFailure('Failed to parse events: ${e.toString()}'),
              ),
            );
          }
        },
        handleError: (error, stackTrace, sink) {
          if (error is ServerException) {
            sink.add(Left<Failure, List<Event>>(ServerFailure(error.message)));
          } else if (error is NetworkException) {
            sink.add(Left<Failure, List<Event>>(NetworkFailure(error.message)));
          } else {
            sink.add(
              Left<Failure, List<Event>>(
                ServerFailure('Unexpected error: ${error.toString()}'),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Future<Either<Failure, Event>> getEventById(String eventId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final eventModel = await remoteDataSource.getEventById(eventId);
      return Right(eventModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<Event>>> getEventsByOrganization(String orgId) {
    return remoteDataSource.getEventsByOrganization(orgId).transform(
      StreamTransformer<List<EventModel>, Either<Failure, List<Event>>>.fromHandlers(
        handleData: (eventModels, sink) {
          try {
            final events = eventModels.map((model) => model.toEntity()).toList();
            sink.add(Right(events));
          } catch (e) {
            sink.add(
              Left<Failure, List<Event>>(
                ServerFailure('Failed to parse events: ${e.toString()}'),
              ),
            );
          }
        },
        handleError: (error, stackTrace, sink) {
          if (error is ServerException) {
            sink.add(Left<Failure, List<Event>>(ServerFailure(error.message)));
          } else if (error is NetworkException) {
            sink.add(Left<Failure, List<Event>>(NetworkFailure(error.message)));
          } else {
            sink.add(
              Left<Failure, List<Event>>(
                ServerFailure('Unexpected error: ${error.toString()}'),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final eventModel = EventModel.fromEntity(event);
      final createdEventModel = await remoteDataSource.createEvent(eventModel);
      return Right(createdEventModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<Event>>> getEventsByUserAttendance(String userId) {
    return remoteDataSource.getEventsByUserAttendance(userId).transform(
      StreamTransformer<List<EventModel>, Either<Failure, List<Event>>>.fromHandlers(
        handleData: (eventModels, sink) {
          try {
            final events = eventModels.map((model) => model.toEntity()).toList();
            sink.add(Right(events));
          } catch (e) {
            sink.add(
              Left<Failure, List<Event>>(
                ServerFailure('Failed to parse events: ${e.toString()}'),
              ),
            );
          }
        },
        handleError: (error, stackTrace, sink) {
          if (error is ServerException) {
            sink.add(Left<Failure, List<Event>>(ServerFailure(error.message)));
          } else if (error is NetworkException) {
            sink.add(Left<Failure, List<Event>>(NetworkFailure(error.message)));
          } else {
            sink.add(
              Left<Failure, List<Event>>(
                ServerFailure('Unexpected error: ${error.toString()}'),
              ),
            );
          }
        },
      ),
    );
  }
}
