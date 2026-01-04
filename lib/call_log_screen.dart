import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/admin_call_list.dart';
import 'package:myapp/supabase_service.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  _CallListDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = _CallListDataSource(context);
  }

  void _sort<T>(Comparable<T> Function(AdminCallList call) getField, int columnIndex, bool ascending) {
    _dataSource!.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _dataSource = _CallListDataSource(context);
        });
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        children: [
          Theme(
            data: _createDataTableTheme(context, isDarkMode),
            child: PaginatedDataTable(
              showCheckboxColumn: false,
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (int? value) {
                setState(() {
                  _rowsPerPage = value!;
                });
              },
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: _getColumns(),
              source: _dataSource ?? _CallListDataSource(context), // Ensure datasource is not null
              columnSpacing: 20,
              horizontalMargin: 20,
            ),
          ),
        ],
      ),
    );
  }

  ThemeData _createDataTableTheme(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final headingColor = isDarkMode ? Colors.white : Colors.black87;
    final dataColor = isDarkMode ? Colors.white70 : Colors.black87;

    return theme.copyWith(
      cardTheme: theme.cardTheme.copyWith(
        color: isDarkMode ? const Color(0xFF1A1A1A).withAlpha(200) : Colors.white,
        surfaceTintColor: isDarkMode ? null : Colors.white,
        elevation: 0, // Remove shadow from the card itself
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: isDarkMode ? Colors.white.withAlpha(50) : Colors.grey.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      dividerColor: isDarkMode ? Colors.white.withAlpha(50) : Colors.grey.withAlpha(100),
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 56,
        dataRowMinHeight: 55,
        dataRowMaxHeight: 65,
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: headingColor,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        dataTextStyle: TextStyle(
          color: dataColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        headingRowColor: WidgetStateProperty.all(
          isDarkMode ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(50),
        ),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.hovered)) {
            return isDarkMode ? Colors.white.withAlpha(20) : Colors.grey.withAlpha(40);
          }
          return Colors.transparent; // Default row color
        }),
        dividerThickness: 1,
      ),
    );
  }

  List<DataColumn> _getColumns() {
    return [
      DataColumn(
        label: const Text('Start Time'),
        onSort: (columnIndex, ascending) => _sort<DateTime>((d) => d.startTime, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Duration (s)'),
        numeric: true,
        onSort: (columnIndex, ascending) => _sort<num>((d) => d.duration, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Status'),
        onSort: (columnIndex, ascending) => _sort<String>((d) => d.status, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Language'),
        onSort: (columnIndex, ascending) => _sort<String>((d) => d.language, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('STT Quality'),
        onSort: (columnIndex, ascending) => _sort<String>((d) => d.sttQuality, columnIndex, ascending),
      ),
      const DataColumn(label: Text('Repeat')),
    ];
  }
}

class _CallListDataSource extends DataTableSource {
  final BuildContext context;
  List<AdminCallList> _calls = [];
  bool _loading = true;

  _CallListDataSource(this.context) {
    _fetchData();
  }

  Future<void> _fetchData() async {
    _loading = true;
    notifyListeners();
    try {
      _calls = await SupabaseService().getCallList();
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching calls: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _calls.length || _loading) {
      return null;
    }
    final call = _calls[index];

    return DataRow.byIndex(
      index: index,
      onSelectChanged: (isSelected) {
        if (isSelected ?? false) {
          // Implement navigation to call detail screen
        }
      },
      cells: [
        DataCell(Text(DateFormat.yMd().add_jms().format(call.startTime))),
        DataCell(Text(call.duration.toString())),
        DataCell(_buildStatusChip(call.status)),
        DataCell(Text(call.language)),
        DataCell(_buildSttQualityIndicator(call.sttQuality)),
        DataCell(call.isRepeatCaller ? const Icon(Icons.check_circle, color: Colors.teal, size: 20) : const SizedBox()),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _loading ? 10 : _calls.length;

  @override
  int get selectedRowCount => 0;

  void sort<T>(Comparable<T> Function(AdminCallList d) getField, bool ascending) {
    _calls.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'dropped':
        color = Colors.red;
        label = 'Dropped';
        break;
      case 'ongoing':
        color = Colors.orange;
        label = 'Ongoing';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }

  Widget _buildSttQualityIndicator(String quality) {
    Color color;
    switch (quality.toLowerCase()) {
      case 'good':
        color = Colors.cyan;
        break;
      case 'low':
        color = Colors.amber;
        break;
      case 'failed':
        color = Colors.pinkAccent;
        break;
      default:
        return Text(quality);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(quality),
      ],
    );
  }
}
