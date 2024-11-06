part of 'sign_in_bloc.dart';

class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {}

class SignInFailure extends SignInState {}

class SignInProcess extends SignInState {}

class SignInSuccess extends SignInState {}

class SignInPlaceUpdateSuccess extends SignInState {}

class SignInPlaceUpdateFailure extends SignInState {}

class LoadPlacesRequested extends SignInEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  LoadPlacesRequested({this.startDate, this.endDate});

  @override
  List<Object> get props => [startDate ?? '', endDate ?? ''];
}
