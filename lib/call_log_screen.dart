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
  // State for the PaginatedDataTable
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        // In a real app, you'd have filter actions here
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () { 
              // TODO: Implement filter dialog
            },
            tooltip: 'Filter Calls',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            // The datasource will automatically refetch
            _dataSource = _CallListDataSource(context);
          });
        },
        child: SingleChildScrollView(
          child: _dataSource == null
              ? const Center(child: CircularProgressIndicator())
              : PaginatedDataTable(
                  header: const Text('All Calls'),
                  rowsPerPage: _rowsPerPage,
                  onRowsPerPageChanged: (int? value) {
                    setState(() {
                      _rowsPerPage = value!;
                    });
                  },
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: _getColumns(),
                  source: _dataSource!,
                ),
        ),
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
      const DataColumn(label: Text('Repeat Caller')),
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
          // Navigate to detail page
          GoRouter.of(context).go('/calls/${call.callId}');
        }
      },
      cells: [
        DataCell(Text(DateFormat.yMd().add_jms().format(call.startTime))),
        DataCell(Text(call.duration.toString())),
        DataCell(Text(call.status)),
        DataCell(Text(call.language)),
        DataCell(Text(call.sttQuality)),
        DataCell(call.isRepeatCaller ? const Icon(Icons.check_circle, color: Colors.green) : const SizedBox()),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _loading ? 10 : _calls.length; // Show loading indicators

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
}
