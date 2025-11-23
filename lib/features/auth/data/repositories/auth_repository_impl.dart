import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signInWithEmail(
          email: email,
          password: password,
        );
        return Right(userModel.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    // TODO: Implement Google sign in
    return const Left(AuthFailure('Google sign in not implemented yet'));
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    // TODO: Implement Apple sign in
    return const Left(AuthFailure('Apple sign in not implemented yet'));
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signUp(
          email: email,
          password: password,
          displayName: displayName,
        );
        return Right(userModel.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel == null) {
        return const Left(AuthFailure('No user is currently signed in'));
      }
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Get current user failed: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, User?>> get authStateChanges {
    return remoteDataSource.authStateChanges
        .map<Either<Failure, User?>>((userModel) {
      if (userModel == null) {
        return const Right<Failure, User?>(null);
      }
      return Right<Failure, User?>(userModel.toEntity());
    });
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
  }) async {
    // TODO: Implement password reset
    return const Left(AuthFailure('Password reset not implemented yet'));
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    // TODO: Implement profile update
    return const Left(AuthFailure('Profile update not implemented yet'));
  }
}

