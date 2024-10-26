part of 'sign_in_bloc.dart';

class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInRequired extends SignInEvent {
  final MyUser userData;

  const SignInRequired(this.userData);

  @override
  List<Object> get props => [userData];
}

class SignOutRequired extends SignInEvent {}

class UpdatePlaceRequested extends SignInEvent {
  final MyUser userData;
  final String place;

  UpdatePlaceRequested(this.userData, this.place);

  @override
  List<Object> get props => [userData, place];
}

class PlacesLoadInProgress extends SignInState {}

class PlacesLoadSuccess extends SignInState {
  final List<MyUser> places;

  const PlacesLoadSuccess(this.places);

  @override
  List<Object> get props => [places];
}

class PlacesLoadFailure extends SignInState {}
