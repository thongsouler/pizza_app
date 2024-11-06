import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:intl/intl.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu lần đầu với ngày mặc định
    context.read<SignInBloc>().add(LoadPlacesRequested(
        startDate: DateTime(2010, 12, 31), endDate: DateTime(2100, 12, 31)));
  }

  // Hàm chọn ngày bắt đầu và kết thúc
  void _selectDateRange(BuildContext context) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        _startDate = pickedRange.start;
        _endDate = pickedRange.end;
      });

      // Gọi lại LoadPlacesRequested với ngày mới
      context.read<SignInBloc>().add(LoadPlacesRequested(
            startDate: _startDate!,
            endDate: _endDate!.add(Duration(days: 1)),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách người dùng',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: const Text('Chọn khoảng ngày'),
            ),
          ),
          // Hiển thị khoảng thời gian đã chọn
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Chọn từ ngày: ${_formatDate.format(_startDate!)} đến ${_formatDate.format(_endDate!)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
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
              _buildTableCell(user.toPlace, isLongText: true),
            ],
          );
        },
      ),
    );
  }

  _buildTableCell(String? value, {bool isLongText = false}) {
    return ExpandableTableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Align(
          alignment: Alignment.center,
          child: isLongText && value != null && value.length > 30
              ? InkWell(
                  onTap: () {
                    // Hiển thị dialog khi người dùng nhấn vào
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Điểm đến tìm kiếm"),
                          content: Text(value),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Đóng"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    '${value.substring(0, 30)}...', // Giới hạn hiển thị
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )
              : Text(
                  value ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
        ),
      ),
    );
  }
}
