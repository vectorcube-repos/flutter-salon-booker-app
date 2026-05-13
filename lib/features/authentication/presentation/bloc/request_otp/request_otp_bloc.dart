import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_booker_app/features/authentication/domain/usecases/request_otp_usecase.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/request_otp/request_otp_event.dart';
import 'package:salon_booker_app/features/authentication/presentation/bloc/request_otp/request_otp_state.dart';

class RequestOtpBloc extends Bloc<RequestOtpEvent, RequestOtpState> {
  final RequestOtpUseCase requestOtpUseCase;

  RequestOtpBloc(this.requestOtpUseCase) : super(const RequestOtpState()) {
    on<RequestOtpPhoneChanged>(_onPhoneChanged);
    on<RequestOtpSubmitted>(_onSubmitted);
    on<RequestOtpReset>(_onReset);
  }

  void _onReset(RequestOtpReset event, Emitter<RequestOtpState> emit) {
    emit(state.copyWith(status: RequestOtpStatus.initial));
  }

  void _onPhoneChanged(RequestOtpPhoneChanged event, Emitter<RequestOtpState> emit) {
    emit(state.copyWith(
      phone: event.phone,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
    RequestOtpSubmitted event,
    Emitter<RequestOtpState> emit,
  ) async {
    final digitsOnly = state.phone.replaceAll(RegExp(r'\D'), '').trim();
    if (digitsOnly.length < 10) return;
    if (state.status == RequestOtpStatus.loading) return;

    emit(state.copyWith(
      status: RequestOtpStatus.loading,
      errorMessage: null,
    ));

    final result = await requestOtpUseCase.call(RequestOtpParams(phone: digitsOnly));

    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(
            status: RequestOtpStatus.failure,
            errorMessage: failure.message ?? 'Something went wrong. Please try again.',
          ));
        }
      },
      (_) {
        if (!isClosed) {
          emit(state.copyWith(
            status: RequestOtpStatus.success,
            phone: digitsOnly,
          ));
        }
      },
    );
  }
}
