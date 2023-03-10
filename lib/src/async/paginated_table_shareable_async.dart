import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_report/src/async/nav_helper.dart';
import 'package:flutter_report/src/async/async_source.dart';

class PaginatedTableShareableController extends ChangeNotifier {
  String? columnName;
  bool? ascending;
  int? columnIndex;

  void sort(String cName, bool asc, int cIndex) {
    columnName = cName;
    ascending = asc;
    columnIndex = cIndex;
    notifyListeners();
  }
}

class PaginatedTableShareableAsync extends StatefulWidget {
  final AsyncDataSource asyncDataSource;
  final List<DataColumn> columns;
  final PaginatedTableShareableController controller;
  final PaginatorController paginatorController;

  const PaginatedTableShareableAsync(
      {Key? key,
      required this.asyncDataSource,
      required this.columns,
      required this.controller,
      required this.paginatorController})
      : super(key: key);

  @override
  State<PaginatedTableShareableAsync> createState() =>
      _PaginatedTableShareableAsyncState();
}

class _PaginatedTableShareableAsyncState
    extends State<PaginatedTableShareableAsync> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  AsyncDataSource? _dataSource;
  int _initialRow = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      var columnName = widget.controller.columnName ?? '';
      var ascending = widget.controller.ascending ?? false;
      var columnIndex = widget.controller.columnIndex;

      _dataSource!.sort(columnName, ascending);
      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      });
    });
  }

  @override
  void didChangeDependencies() {
    _dataSource ??= widget.asyncDataSource;

    if (getCurrentRouteOption(context) == goToLast) {
      _dataSource!.getTotalRecords().then((count) => setState(() {
            _initialRow = count - _rowsPerPage;
          }));
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AsyncPaginatedDataTable2(
          horizontalMargin: 20,
          checkboxHorizontalMargin: 12,
          columnSpacing: 0,
          wrapInCard: false,
          rowsPerPage: _rowsPerPage,
          autoRowsToHeight: getCurrentRouteOption(context) == autoRows,
          pageSyncApproach: getCurrentRouteOption(context) == dflt
              ? PageSyncApproach.doNothing
              : getCurrentRouteOption(context) == autoRows
                  ? PageSyncApproach.goToLast
                  : PageSyncApproach.goToFirst,
          minWidth: 800,
          fit: FlexFit.tight,
          border: TableBorder(
            top: const BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
            right: BorderSide(color: Colors.grey[300]!),
            verticalInside: BorderSide(color: Colors.grey[300]!),
            horizontalInside: const BorderSide(color: Colors.grey, width: 1),
          ),
          initialFirstRowIndex: _initialRow,
          onPageChanged: (_) {},
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          sortArrowIcon: Icons.keyboard_arrow_up,
          sortArrowAnimationDuration: const Duration(milliseconds: 0),
          onSelectAll: (select) => select != null && select
              ? (getCurrentRouteOption(context) != selectAllPage
                  ? _dataSource!.selectAll()
                  : _dataSource!.selectAllOnThePage())
              : (getCurrentRouteOption(context) != selectAllPage
                  ? _dataSource!.deselectAll()
                  : _dataSource!.deselectAllOnThePage()),
          controller: widget.paginatorController,
          hidePaginator: getCurrentRouteOption(context) == custPager,
          columns: widget.columns,
          empty: Center(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey[200],
                  child: const Text('No data'))),
          source: _dataSource!,
        ),
      ],
    );
  }
}
