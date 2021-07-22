import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_report/src/extensions/datetime_localization.dart';
import 'package:flutter_report/src/report_model.dart';
import 'package:flutter_report/src/share/native_share.dart'
    if (dart.library.html) 'package:flutter_report/src/share/web_downloader.dart'
    as file;

class PaginatedTableReport<K> extends StatefulWidget {
  final ReportModel<K> reportModel;
  final void Function(DateTimeRange)? onDateRangeChanged;
  final Widget? customWidget;
  final Color appBarBackgroundColor;
  final bool showCheckbox;

  const PaginatedTableReport(this.reportModel,
      {this.onDateRangeChanged,
      this.customWidget,
      this.appBarBackgroundColor = Colors.white,
      this.showCheckbox = false});

  @override
  _PaginatedTableReportState createState() => _PaginatedTableReportState<K>();
}

class _PaginatedTableReportState<K> extends State<PaginatedTableReport> {
  ReportModel<K>? _reportModel;

  @override
  Widget build(BuildContext context) {
    _reportModel = (widget as PaginatedTableReport<K>).reportModel;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.appBarBackgroundColor,
        elevation: 0,
        title: Text(_reportModel!.title),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            if (widget.onDateRangeChanged != null) _dateRangePicker(),
            if (widget.customWidget != null) widget.customWidget!,
            _reportDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _dateRangePicker() {
    Locale _locale = Localizations.localeOf(context);

    return InkWell(
      child: ListTile(
        leading: Icon(
          Icons.date_range,
          color: Colors.blue,
        ),
        title: Text(
          '${_reportModel!.dateRange.start.parseToLocalizedDate(locale: _locale.languageCode)} e ${_reportModel!.dateRange.end.parseToLocalizedDate(locale: _locale.languageCode)}',
          style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 18),
        ),
      ),
      onTap: _onDatePickerRangeTapped,
    );
  }

  void _onDatePickerRangeTapped() async {
    final picked = await showDateRangePicker(
        context: context,
        currentDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime.now().add(Duration(days: 360)));

    if (picked != null) {
      widget.onDateRangeChanged!(picked);
    }
  }

  Widget _reportDataTable() {
    return _reportModel != null
        ? Container(
            height: MediaQuery.of(context).size.height + 100,
            width: double.infinity,
            child: _PaginatedDataTable<K>(
              forecastData: _reportModel!.dataSource,
              onExportAndShareTapped: () => shareExcelReport(
                  _reportModel!.excelHeader, _reportModel!.excelData),
              showCheckbox: widget.showCheckbox,
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  Future<void> shareExcelReport(
      List<String> excelHeader, List<List<String>> excelData) async {
    final excel = Excel.createExcel();
    final sheetObject = excel['relatorio'];

    sheetObject.appendRow(excelHeader);
    excelData.forEach((row) => sheetObject.appendRow(row));
    excel.setDefaultSheet(sheetObject.sheetName);
    await file.share(excel.encode()!, 'relatorio_hortify', 'xlsx',
        desc: 'Relatório');
  }
}

class _PaginatedDataTable<K> extends StatefulWidget {
  final void Function()? onExportAndShareTapped;
  final DataTableSourceSort<K>? forecastData;
  final bool showCheckbox;

  const _PaginatedDataTable(
      {Key? key,
      this.onExportAndShareTapped,
      this.forecastData,
      this.showCheckbox = false})
      : super(key: key);

  @override
  _PaginatedDataTableState createState() => _PaginatedDataTableState<K>();
}

class _PaginatedDataTableState<K> extends State<_PaginatedDataTable> {
  int? _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  DataTableSourceSort<K>? _forecastDataSource;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _forecastDataSource = (widget as _PaginatedDataTable<K>).forecastData;
  }

  @override
  void didUpdateWidget(_PaginatedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _forecastDataSource = (widget as _PaginatedDataTable<K>).forecastData;
  }

  @override
  Widget build(BuildContext context) {
    return _forecastDataSource != null
        ? PaginatedDataTable(
            showCheckboxColumn: widget.showCheckbox,
            header: _exportButton(),
            rowsPerPage: _rowsPerPage!,
            onRowsPerPageChanged: (value) =>
                setState(() => _rowsPerPage = value),
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: _forecastDataSource!.tableHeaders(sort),
            source: _forecastDataSource!,
          )
        : Center(child: CircularProgressIndicator());
  }

  Widget _exportButton() {
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Theme.of(context).primaryColor,
      child: Text(
        'Exportar',
        style:
            Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
      ),
      onPressed: widget.onExportAndShareTapped,
    );
  }

  void sort<T>(
      GetComparableField<T, K> getField, int columnIndex, bool ascending) {
    _forecastDataSource!.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}
