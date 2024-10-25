import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/components/custom_appbar.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
import 'package:pizza_app/screens/home/views/details_screen.dart';

class ListPlaceScreen extends StatefulWidget {
  final String placeType; // "class" or "work"

  const ListPlaceScreen({super.key, required this.placeType});

  @override
  _ListPlaceScreenState createState() => _ListPlaceScreenState();
}

class _ListPlaceScreenState extends State<ListPlaceScreen> {
  String searchQuery = '';
  late final SignInBloc manager;
  String? selectedUnit;

  // Updated units list with "Tất cả" (All)
  final List<String> units = ['Tất cả', '6', '7', '8', '9'];

  @override
  void initState() {
    manager = context.read<SignInBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: manager,
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(
          manager: manager,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Box
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.lightGreen),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  hintText:
                      'Tìm kiếm ${widget.placeType == "class" ? "lớp học" : "nơi làm việc"}...',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              Visibility(
                  visible: widget.placeType == 'class',
                  child: _buildUnitSelection()),

              const SizedBox(height: 16.0),

              // Pizza List for the selected place type
              Expanded(
                child: _buildPizzaList(context, widget.placeType),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: units.map((unit) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedUnit = unit == 'Tất cả' ? null : unit;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: selectedUnit == unit ? Colors.green : Colors.white,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              unit == "Tất cả" ? "Tất cả" : "Khối $unit",
              style: TextStyle(
                color: selectedUnit == unit ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPizzaList(BuildContext context, String location) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: BlocBuilder<GetPizzaBloc, GetPizzaState>(
        builder: (context, state) {
          if (state is GetPizzaSuccess) {
            final filteredPizzas = state.pizzas.where((pizza) {
              return pizza.location == location &&
                  removeDiacritics((pizza.name ?? '').toLowerCase())
                      .contains(removeDiacritics(searchQuery.toLowerCase())) &&
                  (selectedUnit == null || pizza.unit == selectedUnit);
            }).toList();

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 4
                        : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 1,
              ),
              itemCount: filteredPizzas.length,
              itemBuilder: (context, int i) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: manager,
                                ),
                              ],
                              child: DetailsScreen(filteredPizzas[i]),
                            );
                          },
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          filteredPizzas[i].name ?? '',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            filteredPizzas[i].room ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is GetPizzaLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text("An error has occurred..."),
            );
          }
        },
      ),
    );
  }
}
