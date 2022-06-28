import 'package:flutter/material.dart';
import 'package:flutter_report/src/extensions/datetime_localization.dart';
import 'package:flutter_report/src/report_model.dart';
import 'package:flutter_report/src/share/native_share.dart'
    if (dart.library.html) 'package:flutter_report/src/share/web_downloader.dart'
    as file;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class PaginatedTableReport<K> extends StatefulWidget {
  final ReportModel<K> reportModel;
  final void Function(DateTimeRange)? onDateRangeChanged;
  final void Function(int)? onPageChanged;
  final Widget? customWidget;
  final Color appBarBackgroundColor;
  final bool showCheckbox;

  const PaginatedTableReport(this.reportModel,
      {this.onDateRangeChanged,
      this.onPageChanged,
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
              onPageChanged: widget.onPageChanged,
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  Future<void> shareExcelReport(
      List<String> excelHeader, List<List<dynamic>> excelData) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'relatorio';

    excelData.insert(0, excelHeader);

    //data
    for (var rowIndex = 0; rowIndex < excelData.length; rowIndex++) {
      for (var colIx = 0; colIx < excelData[rowIndex].length; colIx++) {
        final _row = rowIndex + 1, _col = colIx + 1;
        final _value = excelData[rowIndex][colIx];
        final _range = sheet.getRangeByIndex(_row, _col);
        _range.setValue(_value);
        if (_value is double) {
          _range.numberFormat = r'#,##0.00';
        }
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    await file.share(bytes, 'relatorio_excel', 'xlsx', desc: 'Relatório');
    workbook.dispose();
  }
}

class _PaginatedDataTable<K> extends StatefulWidget {
  final void Function()? onExportAndShareTapped;
  final void Function(int)? onPageChanged;
  final DataTableSourceSort<K>? forecastData;
  final bool showCheckbox;

  const _PaginatedDataTable(
      {Key? key,
      this.onExportAndShareTapped,
      this.onPageChanged,
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
            onPageChanged: widget.onPageChanged,
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
