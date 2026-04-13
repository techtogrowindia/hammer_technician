import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class SendOtpSuccess extends ForgotPasswordState {
  final String message;
  SendOtpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VerifyOtpSuccess extends ForgotPasswordState {
  final String resetToken;
  final String message;
  VerifyOtpSuccess({required this.resetToken, required this.message});

  @override
  List<Object?> get props => [resetToken, message];
}

class ResetPasswordSuccess extends ForgotPasswordState {
  final String message;
  ResetPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String message;
  ForgotPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}
