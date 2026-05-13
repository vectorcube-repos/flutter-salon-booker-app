import 'package:salon_booker_app/core/utils/typedef.dart';

abstract class UseCase<T, Params> {
  ResultFuture<T> call(Params params);
}
