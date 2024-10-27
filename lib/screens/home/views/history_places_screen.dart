import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:user_repository/user_repository.dart';

class PlacesScreen extends StatefulWidget {
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final GlobalKey _tableKey = GlobalKey();
  String? _nameFilter;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<SignInBloc>().add(LoadPlacesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng',  style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),),
        backgroundColor: Colors.lightGreen,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<SignInBloc, SignInState>(
              builder: (context, state) {
                if (state is PlacesLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PlacesLoadFailure) {
                  return const Center(child: Text('Không thể tải dữ liệu.'));
                } else if (state is PlacesLoadSuccess) {
                  return RepaintBoundary(
                    key: _tableKey,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: _buildExpandableTable(
                          state.places,
                          _nameFilter,
                          _isAscending,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTable(
      List<MyUser> places, String? filter, bool isAscending) {
    final List<String> _headers = <String>[
      'Thời gian',
      'Họ và tên',
      'CCCD',
      'Địa chỉ',
      'Điểm đến tìm kiếm'
    ];

    var filteredPlaces = filter != null
        ? places.where((place) => place.name!.contains(filter)).toList()
        : places;

    filteredPlaces.sort((a, b) {
      final idA = a.userId ?? '';
      final idB = b.userId ?? '';
      return isAscending ? idA.compareTo(idB) : idB.compareTo(idA);
    });

    return ExpandableTable(
      defaultsColumnWidth: 150,
      headerHeight: 60,
      firstColumnWidth: 50,
      visibleScrollbar: true,
      firstHeaderCell: ExpandableTableCell(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(.1),
          ),
          child: const Center(child: Text('STT')),
        ),
      ),
      headers: _headers.map((header) {
        if (header == 'ID') {
          return ExpandableTableHeader(
            cell: ExpandableTableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                    onPressed: () {
                      setState(() {
                        _isAscending = !_isAscending;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return ExpandableTableHeader(
            cell: ExpandableTableCell(
              child: Container(
                color: Colors.grey.withOpacity(.1),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        }
      }).toList(),
      rows: List.generate(
        filteredPlaces.length,
        (index) {
          final user = filteredPlaces[index];
          return ExpandableTableRow(
            firstCell: _buildTableCell('${index + 1}'),
            cells: [
              _buildTableCell(user.userId),
              _buildTableCell(user.name),
              _buildTableCell(user.idcode),
              _buildTableCell(user.address),
              _buildTableCell(user.toPlace),
            ],
          );
        },
      ),
    );
  }

  _buildTableCell(String? value) {
    return ExpandableTableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            value ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
