import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc(this._userRepository) : super(SignInInitial()) {
    on<SignInRequired>((event, emit) async {
      emit(SignInProcess());
      try {
        await _userRepository.signIn(event.userData);
      } catch (e) {
        emit(SignInFailure());
      }
    });

    on<SignOutRequired>((event, emit) async => await _userRepository.logOut());

    on<UpdatePlaceRequested>((event, emit) async {
      try {
        await _userRepository.setPlace(
            event.userData.userId ?? '', event.place);
        emit(SignInPlaceUpdateSuccess());
      } catch (e) {
        emit(SignInPlaceUpdateFailure());
      }
    });

    on<LoadPlacesRequested>((event, emit) async {
      emit(PlacesLoadInProgress());
      try {
        print('Fetch data from Firestore where only is filtered');
        final placesSnapshot = await FirebaseFirestore.instance
            .collection('user_login')
            .where('name', isNotEqualTo: 'admin')
            .get();

        // Filter the results on the client side by comparing timestamps with startDate and endDate
        DateTime startDate = event.startDate!;
        DateTime endDate = event.endDate!;

        // Filter the documents based on timestamp (checking for null)
        final places = placesSnapshot.docs.where((doc) {
          final data = doc.data();
          final timestamp = data['timestamp'];
          if (timestamp != null) {
            final date = timestamp.toDate();
            return date.isAfter(startDate) && date.isBefore(endDate);
          }
          return false; // Exclude if timestamp is null or not a valid Timestamp
        }).map((doc) {
          final data = doc.data();
          return MyUser(
            userId: data['userId'],
            name: data['name'],
            toPlace: data['toPlace'],
            idcode: data['idcode'],
            address: data['address'],
          );
        }).toList();

        emit(PlacesLoadSuccess(places));
      } catch (e) {
        emit(PlacesLoadFailure());
      }
    });
  }
}
