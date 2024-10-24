import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
import 'package:pizza_app/screens/home/views/details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = ''; // Biến để lưu trữ truy vấn tìm kiếm

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Thêm listener để theo dõi sự thay đổi tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Khi tab đang được thay đổi
        print("Tab is changing to index: ${_tabController.index}");
        setState(() {
          
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Row(
          children: [
            Icon(Icons.school),
            SizedBox(width: 8),
            Text(
              'THCS HẢI XUÂN',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<SignInBloc>().add(SignOutRequired());
            },
            icon: const Icon(CupertinoIcons.arrow_right_to_line),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Cập nhật truy vấn tìm kiếm
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.lightGreen),
                ),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm kiếm lớp học/phòng làm việc...',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),

            // TabBar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 2), // Viền bao quanh indicator
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.green, // Màu nền của indicator
                  borderRadius: BorderRadius.circular(6), // Bo góc cho indicator
                ),
                physics: const NeverScrollableScrollPhysics(),
                onTap: (index){
                  setState(() {
                    
                  });
                },
                tabs: [
                  Tab(
                    child: Container(
                      child: Center(
                        child: Text(
                          "Lớp học",
                          style: TextStyle(
                            color: _tabController.index == 0 ? Colors.white : Colors.black, // Đổi màu chữ
                          ),
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      child: Center(
                        child: Text(
                          "Nơi làm việc",
                          style: TextStyle(
                            color: _tabController.index == 1 ? Colors.white : Colors.black, // Đổi màu chữ
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách pizza theo tab đã chọn
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPizzaList(context, "class"),
                  _buildPizzaList(context, "work"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPizzaList(BuildContext context, String location) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: BlocBuilder<GetPizzaBloc, GetPizzaState>(
        builder: (context, state) {
          if (state is GetPizzaSuccess) {
            final filteredPizzas = state.pizzas.where((pizza) =>
                pizza.location == location &&
                pizza.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3/1,
              ),
              itemCount: filteredPizzas.length,
              itemBuilder: (context, int i) {
                return Container(
                  // height: 300,
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
                          builder: (BuildContext context) =>
                              DetailsScreen(filteredPizzas[i]),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image.network(
                        //   filteredPizzas[i].picture,
                        //   fit: BoxFit.cover,
                        //   height: 150,
                        //   width: double.infinity,
                        // ),
                        // const SizedBox(height: 8.0),
                        Text(
                          filteredPizzas[i].name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            filteredPizzas[i].description,
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
