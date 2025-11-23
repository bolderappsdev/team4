import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base interface for all use cases in the application.
///
/// A use case represents a single business operation.
/// It takes [Params] as input and returns [Either<Failure, Type>].
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base interface for stream use cases in the application.
///
/// A stream use case represents a single business operation that returns
/// a stream of results. It takes [Params] as input and returns
/// [Stream<Either<Failure, Type>>].
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Used for use cases that don't require parameters.
///
/// Example:
/// ```dart
/// class GetCurrentUser implements UseCase<User, NoParams> {
///   @override
///   Future<Either<Failure, User>> call(NoParams params) async {
///     // implementation
///   }
/// }
/// ```
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
