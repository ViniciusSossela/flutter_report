import 'package:flutter/material.dart';

typedef GetComparableField<T, K> = Comparable<T> Function(K d);

abstract class DataTableSourceSort<K> extends DataTableSource {
  void sort<T>(GetComparableField<T, K> getField, bool ascending);
  List<DataColumn> tableHeaders(
      void Function<T>(Comparable<T> Function(K d) getField, int columnIndex,
              bool ascending)
          sort);
}

class ReportModel<K> {
  final String title;
  final DateTimeRange dateRange;
  final DataTableSourceSort<K> dataSource;
  final List<String> excelHeader;
  final List<List<String>> excelData;

  ReportModel({
    @required this.dataSource,
    @required this.title,
    @required this.dateRange,
    @required this.excelHeader,
    @required this.excelData,
  }) : assert(dataSource != null &&
            title != null &&
            dateRange != null &&
            excelHeader != null &&
            excelData != null);
}
