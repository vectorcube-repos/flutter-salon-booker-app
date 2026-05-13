import 'package:fpdart/fpdart.dart';
import 'package:salon_booker_app/core/errors/failure.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
