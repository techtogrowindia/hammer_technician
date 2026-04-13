import 'package:equatable/equatable.dart';

abstract class FetchKeyState extends Equatable {
  const FetchKeyState();

  @override
  List<Object?> get props => [];
}

class FetchKeyInitial extends FetchKeyState {}

class FetchKeyLoading extends FetchKeyState {}

class FetchKeyLoaded extends FetchKeyState {
  final int amount;
  final String razorpayKey;

  const FetchKeyLoaded({
    required this.amount,
    required this.razorpayKey,
  });

  @override
  List<Object?> get props => [amount, razorpayKey];
}

class FetchKeyError extends FetchKeyState {
  final String message;

  const FetchKeyError(this.message);

  @override
  List<Object?> get props => [message];
}
