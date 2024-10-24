part of 'get_pizza_bloc.dart';

class GetPizzaState extends Equatable {
  const GetPizzaState();
  
  @override
  List<Object> get props => [];
}

 class GetPizzaInitial extends GetPizzaState {}

 class GetPizzaFailure extends GetPizzaState {}
 class GetPizzaLoading extends GetPizzaState {}
 class GetPizzaSuccess extends GetPizzaState {
  final List<Pizza> pizzas;

  const GetPizzaSuccess(this.pizzas);

  @override
  List<Object> get props => [pizzas];
}
